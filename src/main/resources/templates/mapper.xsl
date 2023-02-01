<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="utf-8" indent="yes" method="text" standalone="yes"/>
	<xsl:param name="schema"/>
	<xsl:param name="table"/>
	<xsl:param name="package"/>
	<xsl:param name="step"/>
	<xsl:param name="suffix"/>
	<xsl:param name="entityClass"/>
	<xsl:param name="entityPackage"/>
	<xsl:param name="dtoClass"/>
	<xsl:param name="dtoPackage"/>
	<xsl:param name="dtoSuffix"/>
	<xsl:template match="/dataBaseStructure">package <xsl:value-of select="$package"/>;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import <xsl:value-of select="$entityPackage"/>.<xsl:value-of select="$entityClass"/>;
import <xsl:value-of select="$dtoPackage"/>.<xsl:value-of select="$dtoClass"/>;

import java.util.List;

<xsl:for-each select="schemas/entry/value/tables/entry[key=$table]/value">
@Mapper(componentModel = "spring")
public abstract class <xsl:value-of select="@className"/><xsl:value-of select="$suffix"/> {

	public abstract <xsl:value-of select="$dtoClass"/> toDTO(<xsl:value-of select="$entityClass"/> <xsl:text> </xsl:text><xsl:value-of select="@methodName"/>);

	public abstract List&lt;<xsl:value-of select="$dtoClass"/>&gt; toDTOs(List&lt;<xsl:value-of select="$entityClass"/>&gt; <xsl:value-of select="@methodName"/>s);


	public abstract <xsl:value-of select="$entityClass"/> toNewEntity(<xsl:value-of select="$dtoClass"/><xsl:text> </xsl:text><xsl:value-of select="@methodName"/><xsl:value-of
		select="$dtoSuffix"/>);

	public abstract <xsl:value-of select="$entityClass"/> toEntity(@MappingTarget <xsl:value-of select="$entityClass"/><xsl:text> </xsl:text><xsl:value-of select="@methodName"/>, <xsl:value-of select="$dtoClass"/><xsl:text> </xsl:text><xsl:value-of select="@methodName"/><xsl:value-of
		select="$dtoSuffix"/>);

</xsl:for-each>}
	</xsl:template>
<!--
//
//
//
-->
</xsl:stylesheet>