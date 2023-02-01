<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="utf-8" indent="yes" method="text" standalone="yes"/>
	<xsl:param name="schema"/>
	<xsl:param name="table"/>
	<xsl:param name="package"/>
	<xsl:param name="step"/>
	<xsl:param name="suffix-model"/>
	<xsl:param name="suffix-data"/>
	<xsl:template match="/dataBaseStructure">
		<xsl:choose>
			<xsl:when test="$step = 'model'"><xsl:call-template name="createModel"/></xsl:when>
			<xsl:when test="$step = 'model-data'"><xsl:call-template name="createData"/></xsl:when>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="createModel">package <xsl:value-of select="$package"/>;

import lombok.Data;

import java.io.Serializable;
import ru.aeroflot.dict.api.model.DictionaryInfo;
import java.time.ZonedDateTime;

<xsl:for-each select="schemas/entry/value/tables/entry[key=$table]/value">
@Data
public class <xsl:value-of select="@className"/><xsl:value-of select="$suffix-model"/> implements DictionaryInfo, Serializable  {
	<xsl:for-each select="columns/entry">
	<xsl:if test="string-length(value/@comment) != 0">
	/** <xsl:value-of select="value/@comment" disable-output-escaping="yes"/> */</xsl:if>
	private <xsl:value-of select="value/@shortType"/><xsl:text> </xsl:text><!-- xsl:if test="value/@isPrimaryKey='true'"><xsl:if test="value/@shortType='Integer'">source</xsl:if></xsl:if --><xsl:value-of select="value/@methodName"/>;
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

	private List&lt;<xsl:value-of select="@className"/><xsl:value-of select="$suffix-model"/>&gt; <xsl:value-of select="@methodName"/><xsl:value-of select="$suffix-data"/>s;
}
</xsl:for-each>
	</xsl:template>
</xsl:stylesheet>