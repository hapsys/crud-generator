<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="utf-8" indent="yes" method="text" standalone="yes"/>
	<xsl:param name="step"/>
	<xsl:param name="schema"/>
	<xsl:param name="table"/>
	<xsl:param name="repository_package"/>
	<xsl:param name="repository_suffix"/>
	<xsl:param name="entity_package"/>
	<xsl:param name="entity_class_name"/>
	<xsl:param name="save"/>
	<xsl:template match="/dataBaseStructure">package <xsl:value-of select="$repository_package"/>;
<xsl:for-each select="catalogs/entry/value/schemas/entry/value/tables/entry[key=$table]/value"><xsl:variable name="currentTable" select="."/>
<xsl:variable name="metaInfo" select="document('src/main/resources/templates/meta-info.xml')/meta-data"/>
<xsl:variable name="meta" select="$metaInfo/table[@name=$table]"/>
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.repository.CrudRepository;
import org.springframework.data.repository.PagingAndSortingRepository;
import org.springframework.data.domain.Page;
import org.springframework.data.domain.Pageable;
import org.springframework.data.jpa.domain.Specification;
import org.springframework.data.jpa.repository.JpaSpecificationExecutor;
import <xsl:value-of select="$entity_package"/>.<xsl:value-of select="$entity_class_name"/>;

import java.util.List;
import java.util.Optional;
public interface <xsl:value-of select="@className"/><xsl:value-of select="$repository_suffix"/> extends PagingAndSortingRepository&lt;<xsl:value-of select="$entity_class_name"/>, <xsl:call-template name="pk_type"/>&gt;, CrudRepository&lt;<xsl:value-of select="$entity_class_name"/>, <xsl:call-template name="pk_type"/>&gt;<xsl:if test="$meta/filter/column">, JpaSpecificationExecutor&lt;<xsl:value-of select="$entity_class_name"/>&gt;</xsl:if> {

	List &lt;<xsl:value-of select="$entity_class_name"/>&gt; findAll();<xsl:for-each select="indexes/entry[value/@isUniq = 'false' or count(value/columns[@isPrimaryKey = 'false']) != 0]">
		<xsl:choose>
			<xsl:when test="value/@isUniq = 'true'">
	Optional&lt;<xsl:value-of select="$entity_class_name"/>&gt; findOneBy<xsl:call-template name="methodName"/>(<xsl:call-template name="parameters"/>);</xsl:when>
		</xsl:choose>
</xsl:for-each>
	Page&lt;<xsl:value-of select="$entity_class_name"/>&gt; findAll(<xsl:if test="$meta/filter/column">Specification&lt;<xsl:value-of select="$entity_class_name"/>&gt; searchSpecification, </xsl:if>Pageable pageable);

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
		<xsl:choose>
			<xsl:when test="count(columns/entry/value[@isPrimaryKey = 'true']) &gt; 1"><xsl:value-of select="$entity_class_name"/>.<xsl:value-of select="@className"/>Id</xsl:when>
			<xsl:otherwise><xsl:value-of select="columns/entry/value[@isPrimaryKey = 'true']/@shortType"/></xsl:otherwise>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>