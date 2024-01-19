<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="utf-8" indent="yes" method="text" standalone="yes"/>
	<xsl:param name="step"/>
	<xsl:param name="schema"/>
	<xsl:param name="table"/>
	<xsl:param name="model_package"/>
	<xsl:param name="model_suffix"/>
	<xsl:param name="api_package"/>
	<xsl:param name="api_suffix"/>

	<xsl:template match="/dataBaseStructure">
		<xsl:choose>
			<xsl:when test="$step = 'model'"><xsl:call-template name="createModel"/></xsl:when>
			<xsl:when test="$step = 'api'"><xsl:call-template name="createApi"/></xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="createModel">package <xsl:value-of select="$model_package"/>;

import lombok.Data;

import io.swagger.v3.oas.annotations.media.Schema;
import java.io.Serializable;
import com.fasterxml.jackson.databind.JsonNode;
import jakarta.validation.constraints.*;

<xsl:for-each select="catalogs/entry/value/schemas/entry/value/tables/entry[key=$table]/value">
<xsl:variable name="metaInfo" select="document('src/main/resources/templates/meta-info.xml')/meta-data"/>
<xsl:variable name="meta" select="$metaInfo/table[@name=$table]"/>
@Schema(description = "<xsl:value-of select="@comment" disable-output-escaping="yes"/>")
@Data
public class <xsl:value-of select="@className"/><xsl:value-of select="$model_suffix"/> implements Serializable  {
	<xsl:for-each select="columns/entry"><xsl:variable name="columnName" select="value/@name"/>
	<xsl:if test="string-length(value/@comment) != 0"><!-- /** <xsl:value-of select="value/@comment" disable-output-escaping="yes"/> */ -->
	@Schema(description = "<xsl:value-of select="value/@comment" disable-output-escaping="yes"/>")
	</xsl:if>
	<xsl:choose>
		<xsl:when test="count($meta/validation/column[@name = $columnName]) != 0">
	<xsl:value-of select="$meta/validation/column[@name = $columnName]/text()" disable-output-escaping="yes"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:choose>
				<xsl:when test="count($metaInfo/globals/validation/column[@name = $columnName]) != 0">
					<xsl:value-of select="$metaInfo/globals/validation/column[@name = $columnName]/text()" disable-output-escaping="yes"/>
				</xsl:when>
				<xsl:otherwise>
			<xsl:if test="value/@isAutoincrement = 'false'">
	<xsl:if test="value/@isNullable = 'false'">
	@NotNull</xsl:if>
	<xsl:if test="value/@isNullable = 'false' and value/@shortType = 'String'">
	@Size(min = 1, max = <xsl:value-of select="value/@size"/>)</xsl:if>
	<xsl:if test="value/@isNullable = 'true' and value/@shortType = 'String'">
	@Size(max = <xsl:value-of select="value/@size"/>)</xsl:if>
			</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
<xsl:choose>
	<xsl:when test="value/@baseType='jsonb'">
	private JsonNode <xsl:value-of select="value/@methodName"/>;</xsl:when>
	<xsl:otherwise>
	private <xsl:value-of select="value/@shortType"/><xsl:text> </xsl:text><xsl:value-of select="value/@methodName"/>;</xsl:otherwise>
</xsl:choose>
<!--
	private <xsl:value-of select="value/@shortType"/><xsl:text> </xsl:text><xsl:value-of select="value/@methodName"/>;
-->
</xsl:for-each>
</xsl:for-each>}
	</xsl:template>
<!--
//
//
//
-->
	<xsl:template name="createApi">package <xsl:value-of select="$api_package"/>;

import lombok.AllArgsConstructor;
import lombok.Builder;
import lombok.Data;
import lombok.NoArgsConstructor;
import java.io.Serializable;
<xsl:for-each select="catalogs/entry/value/schemas/entry/value/tables/entry[key=$table]/value">
@Data
@AllArgsConstructor
@NoArgsConstructor
@Builder
public class <xsl:value-of select="@className"/><xsl:value-of select="$api_suffix"/> implements Serializable {
		<xsl:for-each select="columns/entry"><xsl:variable name="columnName" select="value/@name"/>
<xsl:choose>
	<xsl:when test="value/@baseType='jsonb'">
	private JsonNode <xsl:value-of select="value/@methodName"/>;</xsl:when>
	<xsl:otherwise>
	private <xsl:value-of select="value/@shortType"/><xsl:text> </xsl:text><xsl:value-of select="value/@methodName"/>;</xsl:otherwise>
</xsl:choose>
		</xsl:for-each>
}
</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>