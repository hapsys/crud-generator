<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:cnv="ru.cninnov.generator.utils.NodeUtils">
	<xsl:output encoding="utf-8" indent="yes" method="text" standalone="yes"/>
	<xsl:param name="schema"/>
	<xsl:param name="table"/>
	<xsl:param name="package"/>
	<xsl:param name="step"/>
	<xsl:param name="suffix"/>
	<xsl:param name="entityClass"/>
	<xsl:param name="entityPackage"/>
	<xsl:param name="save"/>
	<xsl:template match="/dataBaseStructure">package <xsl:value-of select="$package"/>;

import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.scheduling.annotation.Async;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import <xsl:value-of select="$entityPackage"/>.<xsl:value-of select="$entityClass"/>;

import java.util.List;
import java.util.Optional;
<xsl:for-each select="schemas/entry/value/tables/entry[key=$table]/value"><xsl:variable name="currentTable" select="."/>
<xsl:variable name="metaInfo" select="document('src/main/resources/templates/meta-info.xml')/meta-data"/>
<xsl:variable name="meta" select="$metaInfo/table[@name=$table]"/>
public interface <xsl:value-of select="@className"/><xsl:value-of select="$suffix"/> extends PagingAndSortingRepository&lt;<xsl:value-of select="$entityClass"/>, <xsl:call-template name="pk_type"/>&gt; {

	List &lt;<xsl:value-of select="$entityClass"/>&gt; findAll();<xsl:for-each select="indexes/entry[value/@isUniq = 'false' or count(value/columns[@isPrimaryKey = 'false']) != 0]">
		<xsl:choose>
			<xsl:when test="value/@isUniq = 'true'">
	Optional&lt;<xsl:value-of select="$entityClass"/>&gt; findOneBy<xsl:call-template name="methodName"/>(<xsl:call-template name="parameters"/>);</xsl:when>
			<xsl:otherwise>
	<!-- List&lt;<xsl:value-of select="$entityClass"/>&gt; findBy<xsl:call-template name="methodName"/>(<xsl:call-template name="parameters"/>); --></xsl:otherwise>
		</xsl:choose>
</xsl:for-each>
	<xsl:if test="$meta/filter/column">
		<xsl:variable name="filters" select="$meta/filter/column"/>
		<xsl:variable name="combinations" select="cnv:combi($filters)"/>
		<xsl:for-each select="$combinations">
			Page&lt;<xsl:value-of select="$entityClass"/>&gt; findAllBy<xsl:for-each select="column"><xsl:variable name="name" select="@name"/><xsl:variable name="currentColumn" select="$currentTable/columns/entry/value[@name = $name]"/><xsl:if test="position() != 1">And</xsl:if><xsl:value-of select="$currentColumn/@className"/><xsl:if test="@multiple = 'true'">In</xsl:if><xsl:value-of
				select="@suffix"/></xsl:for-each>(<xsl:for-each select="column"><xsl:variable name="name" select="@name"/><xsl:variable name="currentColumn" select="$currentTable/columns/entry/value[@name = $name]"/><xsl:if test="position() != 1">, </xsl:if><xsl:value-of select="$currentColumn/@shortType"/><xsl:if test="@multiple = 'true'">[]</xsl:if><xsl:text> </xsl:text><xsl:value-of
				select="$currentColumn/@methodName"/></xsl:for-each>, Pageable pageable);
		</xsl:for-each>
	</xsl:if>
	//@Async
	//default &lt;S extends <xsl:value-of select="$entityClass"/>&gt; S saveAsync(S entity) { return save(entity); }

</xsl:for-each><xsl:value-of select="$save" disable-output-escaping="yes"/>}
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
	<xsl:template name="pk_type">
		<xsl:value-of select="columns/entry/value[@isPrimaryKey = 'true']/@shortType"/>
	</xsl:template>
</xsl:stylesheet>