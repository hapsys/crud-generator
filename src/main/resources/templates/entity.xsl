<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="utf-8" indent="yes" method="text" standalone="yes"/>
	<xsl:param name="step"/>
	<xsl:param name="catalogue"/>
	<xsl:param name="schema"/>
	<xsl:param name="table"/>
	<xsl:param name="entity_package"/>
	<xsl:param name="entity_suffix"/>
	<xsl:template match="/dataBaseStructure">package <xsl:value-of select="$entity_package"/>;

import lombok.Data;
import jakarta.persistence.Column;
import jakarta.persistence.Entity;
import jakarta.persistence.GeneratedValue;
import jakarta.persistence.GenerationType;
import jakarta.persistence.Id;
import jakarta.persistence.SequenceGenerator;
import jakarta.persistence.Table;
import jakarta.persistence.IdClass;
import org.hibernate.annotations.DynamicInsert;
import lombok.AllArgsConstructor;
import lombok.EqualsAndHashCode;
import java.io.Serializable;
import lombok.NoArgsConstructor;

<xsl:for-each select="catalogs/entry/value/schemas/entry/value/tables/entry[key=$table]/value">
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
@Table(name = "<xsl:value-of select="$table"/>"<xsl:if test="string-length($schema) != 0"> , schema = "<xsl:value-of select="$schema"/>"</xsl:if>)
<xsl:if test="count(columns/entry/value[@isPrimaryKey = 'true']) &gt; 1">@IdClass(<xsl:value-of select="@className"/><xsl:value-of select="$entity_suffix"/>.<xsl:value-of select="@className"/>Id.class)</xsl:if>
public class <xsl:value-of select="@className"/><xsl:value-of select="$entity_suffix"/> {
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
</xsl:for-each><xsl:if test="count(columns/entry/value[@isPrimaryKey = 'true']) &gt; 1">
	@Data
	@AllArgsConstructor
	@EqualsAndHashCode
	@NoArgsConstructor
	public static class <xsl:value-of select="@className"/>Id implements Serializable {
	<xsl:for-each select="columns/entry/value[@isPrimaryKey = 'true']">
		private <xsl:value-of select="@shortType"/><xsl:text> </xsl:text><xsl:value-of select="@methodName"/>;
	</xsl:for-each>
	}</xsl:if>
</xsl:for-each>
}
	</xsl:template>
<!--
//
//
//
-->
</xsl:stylesheet>