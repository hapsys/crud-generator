<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
				xmlns:csl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="utf-8" indent="yes" method="text" standalone="yes"/>
	<xsl:param name="schema"/>
	<xsl:param name="table"/>
	<xsl:param name="package"/>
	<xsl:param name="step"/>
	<xsl:param name="suffix"/>
	<xsl:param name="suffix-data"/>
	<xsl:template match="/dataBaseStructure">
package <xsl:value-of select="$package"/>;

import lombok.Data;
import io.swagger.v3.oas.annotations.media.Schema;
import ru.aeroflot.dict.meta.ColumnMetainfo;

<xsl:for-each select="schemas/entry/value/tables/entry[key=$table]/value">
<xsl:variable name="metaInfo" select="document('src/main/resources/templates/meta-info.xml')/meta-data"/>
<xsl:variable name="meta" select="$metaInfo/table[@name=$table]"/>
@Data
public class <xsl:value-of select="@className"/><xsl:value-of select="$suffix"/> {
	private String tableComment = "<xsl:value-of select="value/@comment" disable-output-escaping="yes"/>";
	<xsl:for-each select="columns/entry"><xsl:variable name="columnName" select="value/@name"/>
	<xsl:if test="string-length(value/@comment) != 0">
	@Schema(description = "<xsl:value-of select="value/@comment" disable-output-escaping="yes"/>")</xsl:if>
	<xsl:variable name="columnSort" select="$meta/sort/column[@name = $columnName]"/><xsl:variable name="columnFilter" select="$meta/filter/column[@name = $columnName]"/>
	private ColumnMetainfo <xsl:value-of select="value/@methodName"/> = new ColumnMetainfo(
		"<xsl:value-of select="value/@name"/>",
		"<xsl:value-of select="value/@baseType"/>",  
		<xsl:value-of select="value/@isPrimaryKey"/>,
		<xsl:value-of select="value/@isAutoincrement"/>,
		<xsl:value-of select="value/@isNullable"/>,
		"<xsl:value-of select="value/@methodName"/>",
		"<xsl:value-of select="value/@className"/>",
		"<xsl:value-of select="value/@shortType"/>",
		<xsl:value-of select="value/@size"/>,
		"<xsl:value-of select="value/@comment" disable-output-escaping="yes"/>",
		<xsl:choose><xsl:when test="$columnSort">true</xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose>,
		<xsl:choose><xsl:when test="$columnSort/@default = 'true'">true</xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose>,
		<xsl:choose><xsl:when test="$columnFilter">true</xsl:when><xsl:otherwise>false</xsl:otherwise></xsl:choose>
	);
</xsl:for-each>
</xsl:for-each>}
	</xsl:template>
<!--
//
//
//
-->
</xsl:stylesheet>