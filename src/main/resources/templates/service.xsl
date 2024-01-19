<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="utf-8" indent="yes" method="text" standalone="yes"/>
	<xsl:param name="step"/>
	<xsl:param name="schema"/>
	<xsl:param name="table"/>
	<xsl:param name="service_package"/>
	<xsl:param name="service_suffix"/>
	<xsl:param name="entityClassName"/>
	<xsl:param name="entity_package"/>
	<xsl:param name="modelClassName"/>
	<xsl:param name="model_package"/>
	<xsl:param name="model_suffix"/>
	<xsl:param name="repository_package"/>
	<xsl:param name="repositoryClassName"/>
	<xsl:param name="repository_suffix"/>
	<xsl:param name="mapperClassName"/>
	<xsl:param name="mapper_package"/>
	<xsl:param name="mapper_suffix"/>
	<xsl:template match="/dataBaseStructure">package <xsl:value-of select="$service_package"/>;

import lombok.Getter;
import org.springframework.data.domain.Sort;
import org.c3s.edgo.msdict.server.paginator.PaginatorData;
import lombok.extern.slf4j.Slf4j;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.PageRequest;
import org.springframework.data.domain.Pageable;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import jakarta.persistence.criteria.Predicate;
import org.springframework.data.jpa.domain.Specification;
import lombok.RequiredArgsConstructor;
import <xsl:value-of select="$repository_package"/>.<xsl:value-of select="$repositoryClassName"/>;
import <xsl:value-of select="$model_package"/>.<xsl:value-of select="$modelClassName"/>;
import <xsl:value-of select="$entity_package"/>.<xsl:value-of select="$entityClassName"/>;
import <xsl:value-of select="$mapper_package"/>.<xsl:value-of select="$mapperClassName"/>;
import org.c3s.edgo.msdict.server.validation.exceptions.EmptyDataException;
import org.c3s.edgo.msdict.server.validation.exceptions.RecordNotFoundException;
import org.c3s.edgo.msdict.server.util.ConvertUtils;

import org.springframework.validation.annotation.Validated;
import jakarta.validation.Valid;
import java.util.HashMap;
import java.util.ArrayList;
import java.util.LinkedHashMap;
import java.util.List;
import java.util.Map;
import java.util.Optional;
import org.c3s.edgo.msdict.server.validation.constraints.Constraint;
import org.c3s.edgo.msdict.server.validation.constraints.ConstraintType;
import org.c3s.edgo.msdict.server.validation.constraints.ConstraintsHolder;


<xsl:for-each select="catalogs/entry/value/schemas/entry/value/tables/entry[key=$table]/value">
<xsl:variable name="currentTable" select="."/>
<xsl:variable name="metaInfo" select="document('src/main/resources/templates/meta-info.xml')/meta-data"/>
<xsl:variable name="meta" select="$metaInfo/table[@name=$table]"/>
@Validated
@Service
@Slf4j
@RequiredArgsConstructor
public class <xsl:value-of select="@className"/><xsl:value-of select="$service_suffix"/> {

	private final <xsl:value-of select="$repositoryClassName"/> repository;
	private final <xsl:value-of select="$mapperClassName"/> mapper;
	private final ConstraintsHolder constraintsHolder;

	public List&lt;<xsl:value-of select="$modelClassName"/>&gt; get<xsl:value-of select="@className"/>s() {
		return mapper.toDTOs(repository.findAll());
	}
	<xsl:variable name="sort" select="$meta/sort/column"/><xsl:variable name="filter" select="$meta/filter/column"/>
	public PaginatorData&lt;<xsl:value-of select="$modelClassName"/>&gt; get<xsl:value-of select="@className"/>sPaging(int page, int size<xsl:if
		test="$sort">, String sorting</xsl:if><xsl:if test="$filter">, Map&lt;String, String&gt; params</xsl:if>) {
		String sortField = null;
		String sortOrder = null;
		Map&lt;String, Object&gt; active = null;

		<xsl:if test="$filter">
		String value = "";
		String value1 = "";
		active = new LinkedHashMap&lt;&gt;();
		<xsl:for-each select="$filter">
			<xsl:variable name="name" select="@name"/><xsl:variable name="currentColumn" select="$currentTable/columns/entry/value[@name = $name]"/>
			<xsl:choose><xsl:when test="@between = 'true'">
			value = params.get("<xsl:value-of select="$name"/>_start");
			value1 = params.get("<xsl:value-of select="$name"/>_end");
			if (value != null &amp;&amp; !"".equals(value) &amp;&amp; value1 != null &amp;&amp; !"".equals(value1)) {
				active.put("<xsl:value-of select="$name"/>_start",<xsl:choose>
				<xsl:when test="$currentColumn/@shortType = 'String'">value</xsl:when>
				<xsl:otherwise><xsl:value-of select="$currentColumn/@shortType"/>.valueOf(value)</xsl:otherwise></xsl:choose>);
				active.put("<xsl:value-of select="$name"/>_end",<xsl:choose>
				<xsl:when test="$currentColumn/@shortType = 'String'">value</xsl:when>
				<xsl:otherwise><xsl:value-of select="$currentColumn/@shortType"/>.valueOf(value1)</xsl:otherwise></xsl:choose>);
			}</xsl:when><xsl:otherwise>
			value = params.get("<xsl:value-of select="$name"/>");
			if (value != null &amp;&amp; !"".equals(value)) {
				<xsl:choose>
					<xsl:when test="@multiple = 'true'">
						active.put("<xsl:value-of select="$name"/>", ConvertUtils.to<xsl:value-of select="$currentColumn/@shortType"/>(value));
					</xsl:when>
					<xsl:otherwise>
						active.put("<xsl:value-of select="$name"/>",<xsl:choose>
							<xsl:when test="$currentColumn/@shortType = 'String'">value</xsl:when>
							<xsl:when test="$currentColumn/@shortType = 'java.math.BigInteger'">java.math.BigInteger.valueOf(Long.valueOf(value))</xsl:when>
							<xsl:otherwise><xsl:value-of select="$currentColumn/@shortType"/>.valueOf(value)</xsl:otherwise>
						</xsl:choose>);
					</xsl:otherwise>
				</xsl:choose>
			}</xsl:otherwise></xsl:choose>
		</xsl:for-each>
		</xsl:if>
		<xsl:choose>
		<xsl:when test="$sort">
		Pageable pageable;
		try {
			<xsl:if test="$sort[@default = 'true']">
			if (sorting == null || sorting.equals("")) {
				sorting = "<xsl:value-of select="$sort[@default = 'true']/@name"/>_<xsl:choose><xsl:when test="$sort[@default = 'true']/@order"><xsl:value-of select="$sort[@default = 'true']/@order"/></xsl:when><xsl:otherwise>asc</xsl:otherwise>
			</xsl:choose>";
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
		<xsl:choose>
		<xsl:when test="$filter">
			Page&lt;<xsl:value-of select="$entityClassName"/>&gt; pageTuts = repository.findAll(getSearchSpecification(active), pageable);
		</xsl:when>
		<xsl:otherwise>
		Page&lt;<xsl:value-of select="$entityClassName"/>&gt; pageTuts = repository.findAll(pageable);</xsl:otherwise></xsl:choose>
<!-- 	if (pageTuts.isEmpty()) {
                throw new EmptyDataException();
            } -->
		List&lt;<xsl:value-of select="$modelClassName"/>&gt; list = mapper.toDTOs(pageTuts.getContent());
		PaginatorData&lt;<xsl:value-of select="$modelClassName"/>&gt; response = new PaginatorData&lt;&gt;(pageTuts.getNumber() + 1, pageTuts.getSize(), pageTuts.getTotalElements(), list, sortField, sortOrder, active);
		return response;
	}

	<xsl:if test="$filter">
	private Specification&lt;<xsl:value-of select="$entityClassName"/>&gt; getSearchSpecification(Map&lt;String, Object&gt; filters) {
		return (entityRoot, query, cb) -&gt; {
			List&lt;Predicate&gt; predicates = new ArrayList&lt;&gt;();
			<xsl:for-each select="$filter"><xsl:variable name="filter_method"><xsl:choose><xsl:when test="string-length(@method) != 0"><xsl:value-of select="@method"/></xsl:when><xsl:otherwise>equal</xsl:otherwise></xsl:choose></xsl:variable><xsl:variable name="name" select="@name"/><xsl:variable name="currentColumn" select="$currentTable/columns/entry/value[@name = $name]"/><xsl:choose><xsl:when test="@between = 'true'">
			if (filters.containsKey("<xsl:value-of select="$name"/>_start") &amp;&amp; filters.containsKey("<xsl:value-of select="$name"/>_end")) {
				predicates.add(cb.between(entityRoot.get("<xsl:value-of select="$currentColumn/@methodName"/>"), (<xsl:value-of select="$currentColumn/@shortType"/>)filters.get("<xsl:value-of select="$name"/>_start"), (<xsl:value-of select="$currentColumn/@shortType"/>)filters.get("<xsl:value-of select="$name"/>_end")));
			}</xsl:when><xsl:when test="@multiple = 'true'">
			if (filters.containsKey("<xsl:value-of select="$name"/>")) {
				predicates.add(entityRoot.get("<xsl:value-of select="$currentColumn/@methodName"/>").in((<xsl:value-of select="$currentColumn/@shortType"/>[])filters.get("<xsl:value-of select="$name"/>")));
			}</xsl:when><xsl:when test="@suffix = 'IgnoreCase'">
			if (filters.containsKey("<xsl:value-of select="$name"/>")) {
				predicates.add(cb.<xsl:value-of select="$filter_method"/>(cb.lower(entityRoot.get("<xsl:value-of select="$currentColumn/@methodName"/>")), ((String)filters.get("<xsl:value-of select="$name"/>")).toLowerCase()));
			}</xsl:when><xsl:when test="@suffix = 'ContainsIgnoreCase'">
				if (filters.containsKey("<xsl:value-of select="$name"/>")) {
				predicates.add(cb.<xsl:value-of select="$filter_method"/>(cb.lower(entityRoot.get("<xsl:value-of select="$currentColumn/@methodName"/>")), "%" + ((String)filters.get("<xsl:value-of select="$name"/>")).toLowerCase() + "%"));
			}</xsl:when><xsl:otherwise>
			if (filters.containsKey("<xsl:value-of select="$name"/>")) {
				predicates.add(cb.<xsl:value-of select="$filter_method"/>(entityRoot.get("<xsl:value-of select="$currentColumn/@methodName"/>"), (<xsl:value-of select="$currentColumn/@shortType"/>)filters.get("<xsl:value-of select="$name"/>")));
			}</xsl:otherwise>
			</xsl:choose></xsl:for-each>
			log.debug("Predicates size: {}", predicates.size());
			return cb.and(predicates.stream().toArray(Predicate[]::new));
		};
	}

	</xsl:if>


	<xsl:variable name="primary" select="columns/entry/value[@isPrimaryKey = 'true']"/>
	public <xsl:value-of select="$modelClassName"/> getById(<xsl:call-template name="pk_parameters"/>) {
		Optional&lt;<xsl:value-of select="$entityClassName"/>&gt; optional = repository.findById(<xsl:call-template name="pk_make"/>);
		if (optional.isEmpty()) {
			throw new RecordNotFoundException("<xsl:value-of select="$primary/@name"/>", <xsl:value-of select="$primary/@methodName"/>);
		}
		return mapper.toDTO(optional.get());
	}

	@Transactional
	public <xsl:value-of select="$modelClassName"/> update<xsl:value-of select="@className"/>ById(<xsl:call-template
		name="pk_parameters"/>, @Valid <xsl:value-of select="$modelClassName"/> sourceDictDto) {
	<xsl:for-each select="indexes/entry/value[@isUniq = 'true']">
		constraintsHolder.put(new Constraint("<xsl:value-of select="@name"/>", ConstraintType.UNIQUE_KEY, new String[]{<xsl:call-template name="names"/>}, new Object[]{<xsl:call-template name="values"/>}));
	</xsl:for-each>
	<xsl:for-each select="columns/entry/value[count(foreignKey) != 0]">
		constraintsHolder.put(new Constraint("<xsl:value-of select="foreignKey/@name"/>", ConstraintType.FOREIGN_KEY, new String[]{"<xsl:value-of
			select="@name"/>", "<xsl:value-of select="foreignKey/@schema"/>.<xsl:value-of select="foreignKey/@table"/>.<xsl:value-of select="foreignKey/column/@name"/>"}, new Object[]{sourceDictDto.get<xsl:value-of select="@className"/>()}));
	</xsl:for-each>
		Optional&lt;<xsl:value-of select="$entityClassName"/>&gt; <xsl:value-of select="@methodName"/> = repository.findById(<xsl:call-template
		name="pk_make"/>);
		if (!<xsl:value-of select="@methodName"/>.isEmpty()) {
			sourceDictDto.set<xsl:value-of select="$primary/@className"/>(<xsl:value-of select="$primary/@methodName"/>);
			<xsl:for-each select="$currentTable/columns/entry/value"><xsl:variable name="currentColumn" select="."/><xsl:choose><xsl:when test="$metaInfo/globals/defaults/column[@name = $currentColumn/@name]/update">sourceDictDto.set<xsl:value-of select="$currentColumn/@className"/>(<xsl:value-of select="$metaInfo/globals/defaults/column[@name = $currentColumn/@name]/update/text()"/>);
			</xsl:when><xsl:otherwise/></xsl:choose>
			</xsl:for-each>

			<xsl:value-of select="$entityClassName"/> entity = <xsl:value-of select="@methodName"/>.get();
			<xsl:if test="string-length($meta/update) != 0">
				<xsl:value-of select="$meta/update" disable-output-escaping="yes"/>
			</xsl:if>
			entity = mapper.toEntity(entity, sourceDictDto);
			return mapper.toDTO(repository.save(entity));
		} else {
			// new Exception
			throw new RecordNotFoundException("<xsl:value-of select="@name"/>", <xsl:value-of select="@methodName"/>);
		}
	}

	@Transactional
	public <xsl:value-of select="$modelClassName"/> create<xsl:value-of select="@className"/>(@Valid <xsl:value-of select="$modelClassName"/> sourceDictDto) {
		<xsl:for-each select="indexes/entry/value[@isUniq = 'true']">
		constraintsHolder.put(new Constraint("<xsl:value-of select="@name"/>", ConstraintType.UNIQUE_KEY, new String[]{<xsl:call-template name="names"/>}, new Object[]{<xsl:call-template name="values"/>}));
		</xsl:for-each>
		<xsl:for-each select="columns/entry/value[count(foreignKey) != 0]">
		constraintsHolder.put(new Constraint("<xsl:value-of select="foreignKey/@name"/>", ConstraintType.FOREIGN_KEY, new String[]{"<xsl:value-of
				select="@name"/>", "<xsl:value-of select="foreignKey/@schema"/>.<xsl:value-of select="foreignKey/@table"/>.<xsl:value-of select="foreignKey/column/@name"/>"}, new Object[]{sourceDictDto.get<xsl:value-of select="@className"/>()}));
		</xsl:for-each>
		<xsl:if test="$primary/@isAutoincrement = 'true'">sourceDictDto.set<xsl:value-of select="$primary/@className"/>(null);</xsl:if>
		<xsl:for-each select="$currentTable/columns/entry/value">
			<xsl:variable name="currentColumn" select="."/>
			<xsl:choose>
				<xsl:when test="$metaInfo/globals/defaults/column[@name = $currentColumn/@name]/create">
		sourceDictDto.set<xsl:value-of select="$currentColumn/@className"/>(<xsl:value-of select="$metaInfo/globals/defaults/column[@name = $currentColumn/@name]/create/text()"/>);</xsl:when>
				<xsl:otherwise/>
			</xsl:choose>
		</xsl:for-each>
		<xsl:if test="string-length($meta/create) != 0">
			<xsl:value-of select="$meta/create" disable-output-escaping="yes"/>
		</xsl:if>
		return mapper.toDTO(repository.save(mapper.toNewEntity(sourceDictDto)));
	}

	@Transactional
	public void delete<xsl:value-of select="@className"/>ById(<xsl:call-template name="pk_parameters"/>) {
		repository.deleteById(<xsl:call-template name="pk_make"/>);
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
	<!--
    //
    //
    //
    -->
	<xsl:template name="pk_parameters"><xsl:for-each select="columns/entry/value[@isPrimaryKey = 'true']"><xsl:if test="position() != 1">, </xsl:if><xsl:value-of select="@shortType"/><xsl:text> </xsl:text><xsl:value-of select="@methodName"/></xsl:for-each>
	</xsl:template>
	<!--
    //
    //
    //
    -->
	<xsl:template name="pk_make">
		<xsl:choose>
			<xsl:when test="count(columns/entry/value[@isPrimaryKey = 'true']) &gt; 1">new <xsl:value-of select="$entityClassName"/>.<xsl:value-of
					select="@className"/>Id(<xsl:for-each select="columns/entry/value[@isPrimaryKey = 'true']"><xsl:if test="position() != 1">, </xsl:if><xsl:value-of select="@methodName"/></xsl:for-each>)</xsl:when>
			<xsl:otherwise><xsl:value-of select="columns/entry/value[@isPrimaryKey = 'true']/@methodName"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

</xsl:stylesheet>