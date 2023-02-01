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
	<xsl:param name="serviceClass"/>
	<xsl:param name="servicePackage"/>
	<xsl:param name="serviceSuffix"/>
	<xsl:template match="/dataBaseStructure">package <xsl:value-of select="$package"/>;

import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.web.bind.annotation.DeleteMapping;
import org.springframework.web.bind.annotation.GetMapping;
import org.springframework.web.bind.annotation.PathVariable;
import org.springframework.web.bind.annotation.PostMapping;
import org.springframework.web.bind.annotation.PutMapping;
import org.springframework.web.bind.annotation.RequestBody;
import org.springframework.web.bind.annotation.RequestMapping;
import org.springframework.web.bind.annotation.RestController;
import <xsl:value-of select="$repositoryPackage"/>.<xsl:value-of select="$repositoryClass"/>;
import <xsl:value-of select="$dtoPackage"/>.<xsl:value-of select="$dtoClass"/>;
import <xsl:value-of select="$entityPackage"/>.<xsl:value-of select="$entityClass"/>;
import <xsl:value-of select="$mapperPackage"/>.<xsl:value-of select="$mapperClass"/>;
import <xsl:value-of select="$servicePackage"/>.<xsl:value-of select="$serviceClass"/>;

import java.util.List;
import java.util.Optional;
import javax.validation.Valid;
import javax.validation.constraints.Min;

<xsl:for-each select="schemas/entry/value/tables/entry[key=$table]/value">
@Slf4j
@RestController
@RequestMapping("/api/v1/<xsl:value-of select="@name"/>")
public class <xsl:value-of select="@className"/><xsl:value-of select="$suffix"/> {

	private <xsl:value-of select="$serviceClass"/> service;
	@Autowired
	public <xsl:value-of select="@className"/><xsl:value-of select="$suffix"/>(<xsl:value-of select="$serviceClass"/> service) {
		this.service = service;
	}

	@GetMapping(value="/")
	public List&lt;<xsl:value-of select="$dtoClass"/>&gt; get<xsl:value-of select="@className"/>s(){
		return service.get<xsl:value-of select="@className"/>s();
	}

	@GetMapping(value="/{id}")
	public <xsl:value-of select="$dtoClass"/> get<xsl:value-of select="@className"/>By<xsl:value-of
		select="columns/entry/value[@isPrimaryKey = 'true']/@className"/>(@PathVariable("id") <xsl:value-of
		select="columns/entry/value[@isPrimaryKey = 'true']/@shortType"/> id){
		<xsl:value-of select="$dtoClass"/> result = service.getBy<xsl:value-of
		select="columns/entry/value[@isPrimaryKey = 'true']/@className"/>(id);
		return result;
	}

	@PostMapping(value="/")
	public void add<xsl:value-of select="@className"/>(@Valid @RequestBody <xsl:value-of select="$dtoClass"/> dto) {
		service.update<xsl:value-of select="@className"/>(dto);
	}

	@PutMapping(value="/")
	public void update<xsl:value-of select="@className"/>(@Valid @RequestBody <xsl:value-of select="$dtoClass"/> dto) {
		service.update<xsl:value-of select="@className"/>(dto);
	}

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