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
	<xsl:param name="repositoryPackage"/>
	<xsl:param name="repositoryClass"/>
	<xsl:param name="repositorySuffix"/>
	<xsl:param name="mapperClass"/>
	<xsl:param name="mapperPackage"/>
	<xsl:param name="mapperSuffix"/>
	<xsl:template match="/dataBaseStructure">package <xsl:value-of select="$package"/>;

import lombok.extern.slf4j.Slf4j;
import org.springframework.stereotype.Service;
import org.springframework.transaction.annotation.Transactional;
import reactor.core.publisher.Flux;
import lombok.RequiredArgsConstructor;
import <xsl:value-of select="$repositoryPackage"/>.<xsl:value-of select="$repositoryClass"/>;
import <xsl:value-of select="$dtoPackage"/>.<xsl:value-of select="$dtoClass"/>;
import <xsl:value-of select="$entityPackage"/>.<xsl:value-of select="$entityClass"/>;
import <xsl:value-of select="$mapperPackage"/>.<xsl:value-of select="$mapperClass"/>;

import java.util.List;
import java.util.Optional;

<xsl:for-each select="schemas/entry/value/tables/entry[key=$table]/value">
@Service
@Slf4j
@RequiredArgsConstructor
public class <xsl:value-of select="@className"/><xsl:value-of select="$suffix"/> {

	private final <xsl:value-of select="$repositoryClass"/> repository;
	private final <xsl:value-of select="$mapperClass"/> mapper;

	public List&lt;<xsl:value-of select="$dtoClass"/>&gt; get<xsl:value-of select="@className"/>s() {
		return mapper.toDTOs(repository.findAll());
	}
	<xsl:variable name="primary" select="columns/entry/value[@isPrimaryKey = 'true']"/>
	public <xsl:value-of select="$dtoClass"/> getBy<xsl:value-of select="$primary/@className"/>(<xsl:value-of select="$primary/@shortType"/><xsl:text> </xsl:text><xsl:value-of select="$primary/@methodName"/>) {
		return mapper.toDTO(repository.findById(<xsl:value-of select="$primary/@methodName"/>).get());
	}

	<xsl:variable name="uniq_index" select="indexes/entry[(value/@isUniq = 'true' and count(value/columns[@isPrimaryKey = 'false']) != 0)]"/>
	public void update<xsl:value-of select="@className"/>(<xsl:value-of select="$dtoClass"/> sourceDictDto) {

		Optional&lt;<xsl:value-of select="$entityClass"/>&gt; <xsl:value-of select="@methodName"/> = repository.<xsl:choose>
			<xsl:when test="count($uniq_index) = 0">findById(sourceDictDto.get<xsl:value-of select="indexes/entry/value/columns[@isPrimaryKey = 'true']/@className"/>());</xsl:when>
			<xsl:otherwise>findOneBy<xsl:value-of select="$uniq_index/value/columns/@className"/>(sourceDictDto.get<xsl:value-of select="$uniq_index/value/columns/@className"/>());</xsl:otherwise>
</xsl:choose>
		if (<xsl:value-of select="@methodName"/>.isEmpty()) {
			//log.info("Airport is not found, created new Airport by id: {}", sourceDictDto.get<xsl:value-of select="$uniq_index/value/columns/@className"/>());
			<xsl:value-of select="$entityClass"/> entity = mapper.toNewEntity(sourceDictDto);
			repository.saveAsync(entity);
			return;
		}
		<xsl:value-of select="$entityClass"/> entity =  <xsl:value-of select="@methodName"/>.get();
		entity = mapper.toEntity(entity, sourceDictDto);
		//log.info("Updating existing Airport Dictionary: {}", sourceDictDto.get<xsl:value-of select="$uniq_index/value/columns/@className"/>());
		repository.saveAsync(entity);
	}

	<!--
	<xsl:for-each select="indexes/entry[value/@isUniq = 'false' or count(value/columns[@isPrimaryKey = 'false']) != 0]">
		<xsl:choose>
			<xsl:when test="value/@isUniq = 'true'">
				Optional&lt;<xsl:value-of select="$entityClass"/>&gt; findOneBy<xsl:call-template name="methodName"/>(<xsl:call-template name="parameters"/>);</xsl:when>
			<xsl:otherwise>
				List&lt;<xsl:value-of select="$entityClass"/>&gt; findBy<xsl:call-template name="methodName"/>(<xsl:call-template name="parameters"/>);</xsl:otherwise>
		</xsl:choose>
	</xsl:for-each>
	-->
</xsl:for-each>
}
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