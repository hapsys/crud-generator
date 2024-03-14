<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:c3s="org.c3s.generator.utils.RegexpUtils">
	<xsl:output encoding="utf-8" indent="yes" method="text" standalone="yes"/>
	<xsl:param name="step"/>
	<xsl:param name="schema"/>
	<xsl:param name="table"/>
	<xsl:param name="service_package"/>
	<xsl:param name="service_suffix"/>
	<xsl:param name="entity_class_name"/>
	<xsl:param name="entity_package"/>
	<xsl:param name="model_class_name"/>
	<xsl:param name="model_package"/>
	<xsl:param name="model_suffix"/>
	<xsl:param name="repository_package"/>
	<xsl:param name="repository_class_name"/>
	<xsl:param name="repository_suffix"/>
	<xsl:param name="mapper_class_name"/>
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
import <xsl:value-of select="$repository_package"/>.<xsl:value-of select="$repository_class_name"/>;
import <xsl:value-of select="$model_package"/>.<xsl:value-of select="$model_class_name"/>;
import <xsl:value-of select="$entity_package"/>.<xsl:value-of select="$entity_class_name"/>;
import <xsl:value-of select="$mapper_package"/>.<xsl:value-of select="$mapper_class_name"/>;
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
<xsl:variable name="globals" select="$metaInfo/globals"/>
<xsl:variable name="meta" select="$metaInfo/table[@name=$table]"/>
<xsl:variable name="cache"><xsl:call-template name="check_cache"><xsl:with-param name="globals" select="$globals"/><xsl:with-param
		name="table" select="$meta"/><xsl:with-param name="table_name" select="$table"/></xsl:call-template></xsl:variable>
<xsl:if test="$cache = 'true'">import org.c3s.edgo.msdict.server.cache.service.ParametrizedCacheService;
import org.c3s.edgo.msdict.server.util.ParameterUtils;
import java.util.TreeSet;</xsl:if>
@Validated
@Service
@Slf4j
@RequiredArgsConstructor
public class <xsl:value-of select="@className"/><xsl:value-of select="$service_suffix"/> {

	private final <xsl:value-of select="$repository_class_name"/> repository;
	private final <xsl:value-of select="$mapper_class_name"/> mapper;
	private final ConstraintsHolder constraintsHolder;<xsl:if test="$cache = 'true'">
	private final ParametrizedCacheService parametrizedCacheService;

	private final static String SCOPE = "<xsl:value-of select="$table"/>";</xsl:if>

	public List&lt;<xsl:value-of select="$model_class_name"/>&gt; get<xsl:value-of select="@className"/>s() {
		return mapper.toDTOs(repository.findAll());
	}
	<xsl:variable name="sort" select="$meta/sort/column"/><xsl:variable name="filter" select="$meta/filter/column"/>
	public PaginatorData&lt;<xsl:value-of select="$model_class_name"/>&gt; get<xsl:value-of select="@className"/>sPaging(int page, int size<xsl:if
		test="$sort">, String sorting</xsl:if><xsl:if test="$filter">, Map&lt;String, String&gt; params</xsl:if>) {

	    <xsl:if test="$cache = 'true'">
		Map&lt;String, String&gt; cacheParams = new HashMap&lt;&gt;() {{
		put("page", String.valueOf(page));
		put("size", String.valueOf(size));
		}};</xsl:if>

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
			if (value != null &amp;&amp; !"".equals(value) &amp;&amp; value1 != null &amp;&amp; !"".equals(value1)) {<xsl:if test="$cache = 'true'">
				cacheParams.put("<xsl:value-of select="$name"/>_start", value);
				cacheParams.put("<xsl:value-of select="$name"/>_end", value1); </xsl:if>
				active.put("<xsl:value-of select="$name"/>_start",<xsl:choose>
				<xsl:when test="$currentColumn/@shortType = 'String'">value</xsl:when>
				<xsl:otherwise><xsl:value-of select="$currentColumn/@shortType"/>.valueOf(value)</xsl:otherwise></xsl:choose>);
				active.put("<xsl:value-of select="$name"/>_end",<xsl:choose>
				<xsl:when test="$currentColumn/@shortType = 'String'">value</xsl:when>
				<xsl:otherwise><xsl:value-of select="$currentColumn/@shortType"/>.valueOf(value1)</xsl:otherwise></xsl:choose>);
			}</xsl:when><xsl:otherwise>
			value = params.get("<xsl:value-of select="$name"/>");
			if (value != null &amp;&amp; !"".equals(value)) {<xsl:if test="$cache = 'true'">
				cacheParams.put("<xsl:value-of select="$name"/>", value);</xsl:if>
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
			</xsl:if><xsl:if test="$cache = 'true'">
			cacheParams.put("sort", sorting);</xsl:if>
			pageable = PageRequest.of(page, size, <xsl:value-of select="@className"/>Sorting.valueOf(sorting).getSortValue());
			sortField = sorting.substring(0, sorting.lastIndexOf('_'));
			sortOrder = sorting.substring(sorting.lastIndexOf('_') + 1);
		} catch (IllegalArgumentException | NullPointerException e) {
			pageable = PageRequest.of(page, size);
		}
		</xsl:when>
		<xsl:otherwise>Pageable pageable = PageRequest.of(page, size);</xsl:otherwise>
		</xsl:choose>
		PaginatorData&lt;<xsl:value-of select="$model_class_name"/>&gt; response;
		<xsl:if test="$cache = 'true'">
		String hash = ParameterUtils.getParameterHash(cacheParams, new TreeSet&lt;&gt;());
		response = parametrizedCacheService.getCacheData(SCOPE, hash, PaginatorData.class);
		if (response == null) {</xsl:if>
		<xsl:choose>
		<xsl:when test="$filter">
			Page&lt;<xsl:value-of select="$entity_class_name"/>&gt; pageTuts = repository.findAll(getSearchSpecification(active), pageable);
		</xsl:when>
		<xsl:otherwise>
		Page&lt;<xsl:value-of select="$entity_class_name"/>&gt; pageTuts = repository.findAll(pageable);</xsl:otherwise></xsl:choose>
<!-- 	if (pageTuts.isEmpty()) {
                throw new EmptyDataException();
            } -->
		List&lt;<xsl:value-of select="$model_class_name"/>&gt; list = mapper.toDTOs(pageTuts.getContent());
		response = new PaginatorData&lt;&gt;(pageTuts.getNumber() + 1, pageTuts.getSize(), pageTuts.getTotalElements(), list, sortField, sortOrder, active);
	    <xsl:if test="$cache = 'true'">
		parametrizedCacheService.insertCacheData(SCOPE, hash, response, false);
		}
		</xsl:if>
		return response;
	}

	<xsl:if test="$filter">
	private Specification&lt;<xsl:value-of select="$entity_class_name"/>&gt; getSearchSpecification(Map&lt;String, Object&gt; filters) {
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
	public <xsl:value-of select="$model_class_name"/> getById(<xsl:call-template name="pk_parameters"/>) {
		<xsl:value-of select="$model_class_name"/> response = null;
		<xsl:if test="$cache = 'true'">String hash = <xsl:call-template name="cache_parameters"/>;
		response = parametrizedCacheService.getCacheData(SCOPE, hash, <xsl:value-of select="$model_class_name"/>.class);
		if (response == null) {
		</xsl:if>
		Optional&lt;<xsl:value-of select="$entity_class_name"/>&gt; optional = repository.findById(<xsl:call-template name="pk_make"/>);
		if (optional.isEmpty()) {
			throw new RecordNotFoundException("<xsl:value-of select="$primary/@name"/>", <xsl:value-of select="$primary/@methodName"/>);
		}
		response = mapper.toDTO(optional.get());
			<xsl:if test="$cache = 'true'">parametrizedCacheService.insertCacheData(SCOPE, hash, response, true);
		}</xsl:if>
		return response;
	}

	@Transactional
	public <xsl:value-of select="$model_class_name"/> update<xsl:value-of select="@className"/>ById(<xsl:call-template
		name="pk_parameters"/>, @Valid <xsl:value-of select="$model_class_name"/> sourceDictDto) {
	<xsl:for-each select="indexes/entry/value[@isUniq = 'true']">
		constraintsHolder.put(new Constraint("<xsl:value-of select="@name"/>", ConstraintType.UNIQUE_KEY, new String[]{<xsl:call-template name="names"/>}, new Object[]{<xsl:call-template name="values"/>}));
	</xsl:for-each>
	<xsl:for-each select="columns/entry/value[count(foreignKey) != 0]">
		constraintsHolder.put(new Constraint("<xsl:value-of select="foreignKey/@name"/>", ConstraintType.FOREIGN_KEY, new String[]{"<xsl:value-of
			select="@name"/>", "<xsl:value-of select="foreignKey/@schema"/>.<xsl:value-of select="foreignKey/@table"/>.<xsl:value-of select="foreignKey/column/@name"/>"}, new Object[]{sourceDictDto.get<xsl:value-of select="@className"/>()}));
	</xsl:for-each>
		Optional&lt;<xsl:value-of select="$entity_class_name"/>&gt; <xsl:value-of select="@methodName"/> = repository.findById(<xsl:call-template
		name="pk_make"/>);
		if (!<xsl:value-of select="@methodName"/>.isEmpty()) {
			sourceDictDto.set<xsl:value-of select="$primary/@className"/>(<xsl:value-of select="$primary/@methodName"/>);
			<xsl:for-each select="$currentTable/columns/entry/value"><xsl:variable name="currentColumn" select="."/><xsl:choose><xsl:when test="$metaInfo/globals/defaults/column[@name = $currentColumn/@name]/update">sourceDictDto.set<xsl:value-of select="$currentColumn/@className"/>(<xsl:value-of select="$metaInfo/globals/defaults/column[@name = $currentColumn/@name]/update/text()"/>);
			</xsl:when><xsl:otherwise/></xsl:choose>
			</xsl:for-each>

			<xsl:value-of select="$entity_class_name"/> entity = <xsl:value-of select="@methodName"/>.get();
			<xsl:if test="string-length($meta/update) != 0">
				<xsl:value-of select="$meta/update" disable-output-escaping="yes"/>
			</xsl:if>
			entity = mapper.toEntity(entity, sourceDictDto);
			<xsl:if test="$cache = 'true'">deleteSingleCache(<xsl:call-template name="pk_make"/>);</xsl:if>
			return mapper.toDTO(repository.save(entity));
		} else {
			// new Exception
			throw new RecordNotFoundException("<xsl:value-of select="@name"/>", <xsl:value-of select="@methodName"/>);
		}
	}

	@Transactional
	public <xsl:value-of select="$model_class_name"/> create<xsl:value-of select="@className"/>(@Valid <xsl:value-of select="$model_class_name"/> sourceDictDto) {
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
		<xsl:if test="$cache = 'true'">deleteSingleCache(<xsl:call-template name="pk_make"/>);</xsl:if>
		repository.deleteById(<xsl:call-template name="pk_make"/>);
	}
	<xsl:if test="$cache = 'true'">
	private void deleteSingleCache(<xsl:call-template name="pk_parameters"/>) {
		String hash = <xsl:call-template name="cache_parameters"/>;
		parametrizedCacheService.deleteCacheData(SCOPE, hash);
		parametrizedCacheService.deleteCacheData(SCOPE);
	}
	</xsl:if>
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
	<xsl:template name="cache_parameters"><xsl:for-each select="columns/entry/value[@isPrimaryKey = 'true']"><xsl:if test="position() != 1"> + "_" + </xsl:if><xsl:value-of select="@methodName"/>.toString()</xsl:for-each>
	</xsl:template>
	<!--
    //
    //
    //
    -->
	<xsl:template name="pk_make">
		<xsl:choose>
			<xsl:when test="count(columns/entry/value[@isPrimaryKey = 'true']) &gt; 1">new <xsl:value-of select="$entity_class_name"/>.<xsl:value-of
					select="@className"/>Id(<xsl:for-each select="columns/entry/value[@isPrimaryKey = 'true']"><xsl:if test="position() != 1">, </xsl:if><xsl:value-of select="@methodName"/></xsl:for-each>)</xsl:when>
			<xsl:otherwise><xsl:value-of select="columns/entry/value[@isPrimaryKey = 'true']/@methodName"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<!--
    //
    //
    //
    -->
	<xsl:template name="check_cache">
		<xsl:param name="globals"/>
		<xsl:param name="table"/>
		<xsl:param name="table_name"/>
		<xsl:choose>
			<xsl:when test="$table/@cache='true'">true</xsl:when>
			<xsl:when test="$table/@cache='false'">false</xsl:when>
			<xsl:otherwise>
				<xsl:choose>
					<xsl:when test="string-length($globals/cache/@regexp) != 0 and c3s:preg_match($globals/cache/@regexp, $table_name)">true</xsl:when>
					<xsl:when test="count($globals/cache/table[text() = $table_name]) != 0">true</xsl:when>
					<xsl:otherwise>false</xsl:otherwise>
				</xsl:choose>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>