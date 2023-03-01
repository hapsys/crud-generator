<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="utf-8" indent="yes" method="text" standalone="yes"/>
	<xsl:param name="schema"/>
	<xsl:param name="table"/>
	<xsl:param name="package"/>
	<xsl:param name="step"/>
	<xsl:param name="suffix"/>
	<xsl:param name="entityClass"/>
	<xsl:param name="entityPackage"/>
	<xsl:param name="dtoClass"/>
	<xsl:param name="dtoPackage"/>
	<xsl:param name="dtoSuffix"/>
	<xsl:param name="repositoryPackage"/>
	<xsl:param name="repositoryClass"/>
	<xsl:param name="repositorySuffix"/>
	<xsl:param name="mapperClass"/>
	<xsl:param name="mapperPackage"/>
	<xsl:param name="mapperSuffix"/>
	<xsl:template match="/dataBaseStructure">package <xsl:value-of select="$package"/>;

import lombok.Getter;
import org.springframework.data.domain.Sort;
import ru.aeroflot.dict.paginator.PaginatorData;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import reactor.core.publisher.Flux;
import lombok.RequiredArgsConstructor;
import <xsl:value-of select="$repositoryPackage"/>.<xsl:value-of select="$repositoryClass"/>;
import <xsl:value-of select="$dtoPackage"/>.<xsl:value-of select="$dtoClass"/>;
import <xsl:value-of select="$entityPackage"/>.<xsl:value-of select="$entityClass"/>;
import <xsl:value-of select="$mapperPackage"/>.<xsl:value-of select="$mapperClass"/>;
import ru.aeroflot.dict.validation.exceptions.EmptyDataException;
import ru.aeroflot.dict.validation.exceptions.RecordNotFoundException;

import org.springframework.validation.annotation.Validated;
import javax.validation.Valid;
import java.util.HashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import ru.aeroflot.dict.validation.constraints.Constraint;
import ru.aeroflot.dict.validation.constraints.ConstraintType;
import ru.aeroflot.dict.validation.constraints.ConstraintsHolder;


<xsl:for-each select="schemas/entry/value/tables/entry[key=$table]/value">
<xsl:variable name="currentTable" select="."/>
<xsl:variable name="metaInfo" select="document('src/main/resources/templates/meta-info.xml')/meta-data"/>
<xsl:variable name="meta" select="$metaInfo/table[@name=$table]"/>
@Validated
@Service
@Slf4j
@RequiredArgsConstructor
public class <xsl:value-of select="@className"/><xsl:value-of select="$suffix"/> {

	private final <xsl:value-of select="$repositoryClass"/> repository;
	private final <xsl:value-of select="$mapperClass"/> mapper;
	private final ConstraintsHolder constraintsHolder;

	public List&lt;<xsl:value-of select="$dtoClass"/>&gt; get<xsl:value-of select="@className"/>s() {
		return mapper.toDTOs(repository.findAll());
	}
	<xsl:variable name="sort" select="$meta/sort/column"/><xsl:variable name="filter" select="$meta/filter/column"/>
	public PaginatorData&lt;<xsl:value-of select="$dtoClass"/>&gt; get<xsl:value-of select="@className"/>sPaging(int page, int size<xsl:if
		test="$sort">, String sorting</xsl:if><xsl:if test="$filter">, String filter, String value</xsl:if>) {
		String sortField = null;
		String sortOrder = null;
		String filterField = null;
		String filterValue = null;
		<xsl:choose>
		<xsl:when test="$sort">
		Pageable pageable;
		try {
			<xsl:if test="$sort[@default = 'true']">
			if (sorting == null || sorting.equals("")) {
				sorting = "<xsl:value-of select="$sort[@default = 'true']/@name"/>_asc";
			}
			</xsl:if>
			pageable = PageRequest.of(page, size, <xsl:value-of select="@className"/>Sorting.valueOf(sorting).getSortValue());
			sortField = sorting.substring(0, sorting.lastIndexOf('_'));
			sortOrder = sorting.substring(sorting.lastIndexOf('_') + 1);
		} catch (IllegalArgumentException | NullPointerException e) {
			pageable = PageRequest.of(page, size);
		}
		</xsl:when>
		<xsl:otherwise>Pageable pageable = PageRequest.of(page, size);</xsl:otherwise>
		</xsl:choose>
		Page&lt;<xsl:value-of select="$entityClass"/>&gt; pageTuts;
		<xsl:choose>
		<xsl:when test="$filter">
		if (value != null &amp;&amp; !"".equals(value)) {
			switch(filter) {
				<xsl:for-each select="$filter"><xsl:variable name="name" select="@name"/><xsl:variable name="currentColumn" select="$currentTable/columns/entry/value[@name = $name]"/>
				case "<xsl:value-of select="$name"/>":
					pageTuts = repository.findAllBy<xsl:value-of select="$currentColumn/@className"/>(value, pageable);
					filterField = "<xsl:value-of select="$name"/>";
					filterValue = value;
					break;
				</xsl:for-each>
				default:
				pageTuts = repository.findAll(pageable);
			}
		} else {
			pageTuts = repository.findAll(pageable);
		}</xsl:when>
		<xsl:otherwise>
		pageTuts = repository.findAll(pageable);</xsl:otherwise></xsl:choose>
		if (pageTuts.isEmpty()) {
			throw new EmptyDataException();
		}
		List&lt;<xsl:value-of select="$dtoClass"/>&gt; list = mapper.toDTOs(pageTuts.getContent());
		PaginatorData&lt;<xsl:value-of select="$dtoClass"/>&gt; response = new PaginatorData&lt;&gt;(pageTuts.getNumber() + 1, pageTuts.getSize(), pageTuts.getTotalElements(), list, sortField, sortOrder, filterField, filterValue);
		return response;
	}


	<xsl:variable name="primary" select="columns/entry/value[@isPrimaryKey = 'true']"/>
	public <xsl:value-of select="$dtoClass"/> getBy<xsl:value-of select="$primary/@className"/>(<xsl:value-of select="$primary/@shortType"/><xsl:text> </xsl:text><xsl:value-of select="$primary/@methodName"/>) {
		Optional&lt;<xsl:value-of select="$entityClass"/>&gt; optional = repository.findById(<xsl:value-of select="$primary/@methodName"/>);
		if (optional.isEmpty()) {
			throw new RecordNotFoundException("<xsl:value-of select="$primary/@name"/>", <xsl:value-of select="$primary/@methodName"/>);
		}
		return mapper.toDTO(optional.get());
	}

	<xsl:variable name="uniq_index" select="indexes/entry[(value/@isUniq = 'true' and count(value/columns[@isPrimaryKey = 'false']) != 0)]"/>
	@Transactional
	public void update<xsl:value-of select="@className"/>(@Valid <xsl:value-of select="$dtoClass"/> sourceDictDto) {

		Optional&lt;<xsl:value-of select="$entityClass"/>&gt; <xsl:value-of select="@methodName"/> = repository.<xsl:choose>
			<xsl:when test="count($uniq_index) = 0">findById(sourceDictDto.get<xsl:value-of select="indexes/entry/value/columns[@isPrimaryKey = 'true']/@className"/>());</xsl:when>
			<xsl:otherwise>findOneBy<xsl:value-of select="$uniq_index/value/columns/@className"/>(sourceDictDto.get<xsl:value-of select="$uniq_index/value/columns/@className"/>());</xsl:otherwise>
</xsl:choose>
		if (<xsl:value-of select="@methodName"/>.isEmpty()) {
			//log.info("Airport is not found, created new Airport by id: {}", sourceDictDto.get<xsl:value-of select="$uniq_index/value/columns/@className"/>());
			<xsl:value-of select="$entityClass"/> entity = mapper.toNewEntity(sourceDictDto);
			repository.save(entity);
			return;
		}
		<xsl:value-of select="$entityClass"/> entity =  <xsl:value-of select="@methodName"/>.get();
		entity = mapper.toEntity(entity, sourceDictDto);
		//log.info("Updating existing Airport Dictionary: {}", sourceDictDto.get<xsl:value-of select="$uniq_index/value/columns/@className"/>());
		repository.save(entity);
	}
	@Transactional
	public <xsl:value-of select="$dtoClass"/> update<xsl:value-of select="@className"/>By<xsl:value-of select="$primary/@className"/>(<xsl:value-of select="$primary/@shortType"/><xsl:text> </xsl:text><xsl:value-of select="$primary/@methodName"/>, @Valid <xsl:value-of select="$dtoClass"/> sourceDictDto) {
	<xsl:for-each select="indexes/entry/value[@isUniq = 'true']">
		constraintsHolder.put(new Constraint("<xsl:value-of select="@name"/>", ConstraintType.UNIQUE_KEY, new String[]{<xsl:call-template name="names"/>}, new Object[]{<xsl:call-template name="values"/>}));
	</xsl:for-each>
	<xsl:for-each select="columns/entry/value[count(foreignKey) != 0]">
		constraintsHolder.put(new Constraint("<xsl:value-of select="foreignKey/@name"/>", ConstraintType.FOREIGN_KEY, new String[]{"<xsl:value-of
			select="@name"/>", "<xsl:value-of select="foreignKey/@schema"/>.<xsl:value-of select="foreignKey/@table"/>.<xsl:value-of select="foreignKey/column/@name"/>"}, new Object[]{sourceDictDto.get<xsl:value-of select="@className"/>()}));
	</xsl:for-each>
		Optional&lt;<xsl:value-of select="$entityClass"/>&gt; <xsl:value-of select="@methodName"/> = repository.findById(<xsl:value-of select="$primary/@methodName"/>);
		if (!<xsl:value-of select="@methodName"/>.isEmpty()) {
			sourceDictDto.set<xsl:value-of select="$primary/@className"/>(<xsl:value-of select="$primary/@methodName"/>);
			<xsl:value-of select="$entityClass"/> entity = <xsl:value-of select="@methodName"/>.get();
			entity = mapper.toEntity(entity, sourceDictDto);
			return mapper.toDTO(repository.save(entity));
		} else {
			// new Exception
			throw new RecordNotFoundException("<xsl:value-of select="@name"/>", <xsl:value-of select="@methodName"/>);
		}
	}

	@Transactional
	public <xsl:value-of select="$dtoClass"/> create<xsl:value-of select="@className"/>(@Valid <xsl:value-of select="$dtoClass"/> sourceDictDto) {
		<xsl:for-each select="indexes/entry/value[@isUniq = 'true']">
		constraintsHolder.put(new Constraint("<xsl:value-of select="@name"/>", ConstraintType.UNIQUE_KEY, new String[]{<xsl:call-template name="names"/>}, new Object[]{<xsl:call-template name="values"/>}));
		</xsl:for-each>
		<xsl:for-each select="columns/entry/value[count(foreignKey) != 0]">
		constraintsHolder.put(new Constraint("<xsl:value-of select="foreignKey/@name"/>", ConstraintType.FOREIGN_KEY, new String[]{"<xsl:value-of
				select="@name"/>", "<xsl:value-of select="foreignKey/@schema"/>.<xsl:value-of select="foreignKey/@table"/>.<xsl:value-of select="foreignKey/column/@name"/>"}, new Object[]{sourceDictDto.get<xsl:value-of select="@className"/>()}));
		</xsl:for-each>
		<xsl:if test="$primary/@isAutoincrement = 'true'">sourceDictDto.set<xsl:value-of select="$primary/@className"/>(null);</xsl:if>
		return mapper.toDTO(repository.save(mapper.toNewEntity(sourceDictDto)));
	}

	@Transactional
	public void delete<xsl:value-of select="@className"/>By<xsl:value-of select="$primary/@className"/>(<xsl:value-of select="$primary/@shortType"/><xsl:text> </xsl:text><xsl:value-of select="$primary/@methodName"/>) {
		repository.deleteById(<xsl:value-of select="$primary/@methodName"/>);
	}
	<xsl:if test="$meta/sort">
	@RequiredArgsConstructor
	@Getter
	public enum <xsl:value-of select="@className"/>Sorting {
		<xsl:for-each select="$meta/sort/column"><xsl:variable name="name" select="@name"/>
		<xsl:value-of select="$name"/>_asc(Sort.by(Sort.Direction.ASC, "<xsl:value-of select="$currentTable/columns/entry/value[@name = $name]/@methodName"/>")),
		<xsl:value-of select="$name"/>_desc(Sort.by(Sort.Direction.DESC, "<xsl:value-of select="$currentTable/columns/entry/value[@name = $name]/@methodName"/>")),
		</xsl:for-each>;
		private final Sort sortValue;
	}

	</xsl:if>

</xsl:for-each>
}
	</xsl:template>
	<!--
    //
    //
    //
    -->
	<xsl:template name="methodName">
		<xsl:for-each select="value/columns">
			<xsl:if test="position() != 1">And</xsl:if>
			<xsl:value-of select="@className"/>
		</xsl:for-each>
	</xsl:template>
	<!--
    //
    //
    //
    -->
	<xsl:template name="parameters">
		<xsl:for-each select="value/columns">
			<xsl:if test="position() != 1">, </xsl:if>
			<xsl:value-of select="@shortType"/><xsl:text> </xsl:text><xsl:value-of select="@methodName"/>
		</xsl:for-each>
	</xsl:template>
	<!--
    //
    //
    //
    -->
	<xsl:template name="names"><xsl:for-each select="columns"><xsl:if test="position() != 1">, </xsl:if>"<xsl:value-of select="@name"/>"</xsl:for-each>
	</xsl:template>
	<!--
    //
    //
    //
    -->
	<xsl:template name="values">
		<xsl:for-each select="columns"><xsl:if test="position() != 1">, </xsl:if>sourceDictDto.get<xsl:value-of select="@className"/>()</xsl:for-each>
	</xsl:template>
	<!--
    //
    //
    //
    -->
	<xsl:template name="pk_type">
		<xsl:value-of select="columns/entry/value[@isPrimaryKey = 'true']/@shortType"/>
	</xsl:template>
</xsl:stylesheet>