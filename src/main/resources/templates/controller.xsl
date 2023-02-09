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
<xsl:variable name="meta" select="document('src/main/resources/templates/meta-info.xml')/meta-data/table[@name=$table]"/>
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Parameter;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.validation.annotation.Validated;
import <xsl:value-of select="$repositoryPackage"/>.<xsl:value-of select="$repositoryClass"/>;
import <xsl:value-of select="$dtoPackage"/>.<xsl:value-of select="$dtoClass"/>;
import <xsl:value-of select="$entityPackage"/>.<xsl:value-of select="$entityClass"/>;
import <xsl:value-of select="$mapperPackage"/>.<xsl:value-of select="$mapperClass"/>;
import <xsl:value-of select="$servicePackage"/>.<xsl:value-of select="$serviceClass"/>;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import javax.validation.Valid;
import javax.validation.constraints.Min;

<xsl:for-each select="schemas/entry/value/tables/entry[key=$table]/value">
<xsl:variable name="mapping"><xsl:choose>
	<xsl:when test="count($meta/controller/mapping) = 0"><xsl:value-of select="@name"/></xsl:when>
	<xsl:otherwise><xsl:value-of select="$meta/controller/mapping/text()"/></xsl:otherwise>
</xsl:choose></xsl:variable>
@Slf4j
@RestController
@Validated
@Tag(name="<xsl:value-of select="@comment"/>", description="Работа с сущностью \"<xsl:value-of select="@comment"/>\"")
@RequestMapping("/api/v1/<xsl:value-of select="$mapping"/>")
public class <xsl:value-of select="@className"/><xsl:value-of select="$suffix"/> {

	private <xsl:value-of select="$serviceClass"/> service;
	@Autowired
	public <xsl:value-of select="@className"/><xsl:value-of select="$suffix"/>(<xsl:value-of select="$serviceClass"/> service) {
		this.service = service;
	}

	@GetMapping(value="")
	public ResponseEntity&lt;Map&lt;String, Object&gt;&gt; get<xsl:value-of select="@className"/>s(@RequestParam(defaultValue = "0") @Parameter(description="Номер страницы") int page, @RequestParam(defaultValue = "25") @Parameter(description="Элементов на странице") int size) {
		return new ResponseEntity&lt;&gt;(service.get<xsl:value-of select="@className"/>sPaging(page, size), HttpStatus.OK);
	}


	@GetMapping(value="/{id}")
	public ResponseEntity&lt;<xsl:value-of select="$dtoClass"/>&gt; get<xsl:value-of select="@className"/>By<xsl:value-of
		select="columns/entry/value[@isPrimaryKey = 'true']/@className"/>(@PathVariable("id") <xsl:value-of
		select="columns/entry/value[@isPrimaryKey = 'true']/@shortType"/> id) {
		<xsl:value-of select="$dtoClass"/> result = service.getBy<xsl:value-of
		select="columns/entry/value[@isPrimaryKey = 'true']/@className"/>(id);
		return new ResponseEntity&lt;&gt;(result, HttpStatus.OK);
	}

	@PostMapping(value="")
	public ResponseEntity&lt;<xsl:value-of select="$dtoClass"/>&gt; add<xsl:value-of select="@className"/>(@Valid @RequestBody <xsl:value-of select="$dtoClass"/> dto) {
		service.update<xsl:value-of select="@className"/>(dto);
		return new ResponseEntity&lt;&gt;(HttpStatus.OK);
	}

	@PutMapping(value="")
	public ResponseEntity&lt;<xsl:value-of select="$dtoClass"/>&gt; update<xsl:value-of select="@className"/>(@Valid @RequestBody <xsl:value-of select="$dtoClass"/> dto) {
		service.update<xsl:value-of select="@className"/>(dto);
		return new ResponseEntity&lt;&gt;(HttpStatus.OK);
	}

	@DeleteMapping(value="/{id}")
	public ResponseEntity&lt;<xsl:value-of select="$dtoClass"/>&gt; delete<xsl:value-of select="@className"/>By<xsl:value-of
		select="columns/entry/value[@isPrimaryKey = 'true']/@className"/>(@PathVariable("id") <xsl:value-of
		select="columns/entry/value[@isPrimaryKey = 'true']/@shortType"/> id) {
		service.deleteById(id);
		return new ResponseEntity&lt;&gt;(HttpStatus.OK);
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