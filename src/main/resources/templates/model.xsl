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
		<xsl:choose>
			<xsl:when test="$step = 'process'"><xsl:call-template name="createModel"/></xsl:when>
			<xsl:when test="$step = 'additional'"><xsl:call-template name="createData"/></xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="createModel">package <xsl:value-of select="$package"/>;

import lombok.Data;

import io.swagger.v3.oas.annotations.media.Schema;
import java.io.Serializable;
import ru.aeroflot.dict.api.model.DictionaryInfo;
import java.time.ZonedDateTime;
import com.fasterxml.jackson.databind.JsonNode;
import javax.validation.constraints.*;

<xsl:for-each select="schemas/entry/value/tables/entry[key=$table]/value">
<xsl:variable name="metaInfo" select="document('src/main/resources/templates/meta-info.xml')/meta-data"/>
<xsl:variable name="meta" select="table[@name=$table]"/>
@Schema(description = "<xsl:value-of select="@comment" disable-output-escaping="yes"/>")
@Data
public class <xsl:value-of select="@className"/><xsl:value-of select="$suffix"/> implements DictionaryInfo, Serializable  {
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
	<xsl:if test="value/@isNullable = 'false'">@NotNull
				</xsl:if>
	<xsl:if test="value/@isNullable = 'false' and value/@shortType = 'String'">@Size(min = 1, max = <xsl:value-of select="value/@size"/>)
				</xsl:if>
			</xsl:if>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:otherwise>
	</xsl:choose>
<xsl:choose>
	<xsl:when test="value/@baseType='jsonb'">private JsonNode <xsl:value-of select="value/@methodName"/>;
	</xsl:when>
	<xsl:otherwise>private <xsl:value-of select="value/@shortType"/><xsl:text> </xsl:text><xsl:value-of select="value/@methodName"/>;
	</xsl:otherwise>
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
	<xsl:template name="createData">package <xsl:value-of select="$package"/>;
import lombok.AllArgsConstructor;
import lombok.Data;
import lombok.NoArgsConstructor;

import java.io.Serializable;
import java.util.List;

<xsl:for-each select="schemas/entry/value/tables/entry[key=$table]/value">
@Data
@AllArgsConstructor
@NoArgsConstructor
public class <xsl:value-of select="@className"/><xsl:value-of select="$suffix-data"/> implements Serializable {

	private List&lt;<xsl:value-of select="@className"/><xsl:value-of select="$suffix"/>&gt; <xsl:value-of select="@methodName"/><xsl:value-of select="$suffix-data"/>s;
}
</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>