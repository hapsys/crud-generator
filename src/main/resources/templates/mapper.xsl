<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="utf-8" indent="yes" method="text" standalone="yes"/>
	<xsl:param name="schema"/>
	<xsl:param name="table"/>
	<xsl:param name="package"/>
	<xsl:param name="step"/>
	<xsl:param name="suffix"/>
	<xsl:param name="entity_package"/>
	<xsl:param name="entityClassName"/>
	<xsl:param name="model_package"/>
	<xsl:param name="modelClassName"/>
	<xsl:param name="mapper_package"/>
	<xsl:param name="mapperClassName"/>
	<xsl:template match="/dataBaseStructure">package <xsl:value-of select="$mapper_package"/>;

import org.mapstruct.Mapper;
import org.mapstruct.Mapping;
import org.mapstruct.MappingTarget;
import <xsl:value-of select="$entity_package"/>.<xsl:value-of select="$entityClassName"/>;
import <xsl:value-of select="$model_package"/>.<xsl:value-of select="$modelClassName"/>;

import java.util.List;

<xsl:for-each select="catalogs/entry/value/schemas/entry/value/tables/entry[key=$table]/value">
@Mapper(componentModel = "spring")
public abstract class <xsl:value-of select="$mapperClassName"/> {

	public abstract <xsl:value-of select="$modelClassName"/> toDTO(<xsl:value-of select="$entityClassName"/> <xsl:text> </xsl:text><xsl:value-of select="@methodName"/>);

	public abstract List&lt;<xsl:value-of select="$modelClassName"/>&gt; toDTOs(List&lt;<xsl:value-of select="$entityClassName"/>&gt; <xsl:value-of select="@methodName"/>s);


	public abstract <xsl:value-of select="$entityClassName"/> toNewEntity(<xsl:value-of select="$modelClassName"/><xsl:text> </xsl:text><xsl:value-of select="@methodName"/><xsl:value-of
		select="$modelClassName"/>);

	public abstract <xsl:value-of select="$entityClassName"/> toEntity(@MappingTarget <xsl:value-of select="$entityClassName"/><xsl:text> </xsl:text><xsl:value-of select="@methodName"/>, <xsl:value-of select="$modelClassName"/><xsl:text> </xsl:text><xsl:value-of select="@methodName"/><xsl:value-of
		select="$modelClassName"/>);

</xsl:for-each>}
	</xsl:template>
<!--
//
//
//
-->
</xsl:stylesheet>