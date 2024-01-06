<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="utf-8" indent="yes" method="text" standalone="yes"/>
	<xsl:param name="schema"/>
	<xsl:param name="table"/>
	<xsl:param name="package"/>
	<xsl:param name="step"/>
	<xsl:param name="suffix"/>
	<xsl:template match="/dataBaseStructure">package <xsl:value-of select="$package"/>;

import lombok.Data;
import javax.persistence.Column;
import javax.persistence.Entity;
import javax.persistence.GeneratedValue;
import javax.persistence.GenerationType;
import javax.persistence.Id;
import javax.persistence.SequenceGenerator;
import javax.persistence.Table;
import org.hibernate.annotations.DynamicInsert;

<xsl:for-each select="schemas/entry/value/tables/entry[key=$table]/value">
<xsl:variable name="canJson" select="count(columns/entry/value[@baseType='jsonb']) != 0"/>
<xsl:if test="$canJson">import com.fasterxml.jackson.databind.JsonNode;
import com.vladmihalcea.hibernate.type.json.JsonBinaryType;
import org.hibernate.annotations.Type;
import org.hibernate.annotations.TypeDef;</xsl:if>
<xsl:if test="string-length(@comment) != 0">
/** <xsl:value-of select="@comment" disable-output-escaping="yes"/> */</xsl:if>
<xsl:if test="$canJson">
@TypeDef(name = "jsonb", typeClass = JsonBinaryType.class)</xsl:if>
@DynamicInsert
@Entity
@Data
@Table(name = "<xsl:value-of select="$table"/>", schema = "<xsl:value-of select="$schema"/>")
public class <xsl:value-of select="@className"/><xsl:value-of select="$suffix"/> {
	<xsl:for-each select="columns/entry">
	<xsl:if test="string-length(value/@comment) != 0">
	/** <xsl:value-of select="value/@comment" disable-output-escaping="yes"/> */</xsl:if>
	<xsl:if test="value/@isPrimaryKey='true'">
	@Id<xsl:if test="value/@shortType='Integer'">
	@GeneratedValue(strategy = GenerationType.IDENTITY)</xsl:if></xsl:if><xsl:if test="value/@baseType='jsonb'">
	@Type(type = "jsonb")</xsl:if>
	@Column(name = "<xsl:value-of select="value/@name"/>")
	<xsl:choose>
		<xsl:when test="value/@baseType='jsonb'">private JsonNode <xsl:value-of select="value/@methodName"/>;
		</xsl:when>
		<xsl:otherwise>private <xsl:value-of select="value/@shortType"/><xsl:text> </xsl:text><xsl:value-of select="value/@methodName"/>;
		</xsl:otherwise>
	</xsl:choose>
</xsl:for-each>
</xsl:for-each>
}
	</xsl:template>
<!--
//
//
//
-->
</xsl:stylesheet>