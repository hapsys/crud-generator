<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
	<xsl:output encoding="utf-8" indent="yes" method="text" standalone="yes"/>
	<xsl:param name="step"/>
	<xsl:param name="schema"/>
	<xsl:param name="table"/>
	<xsl:param name="controller_package"/>
	<xsl:param name="controller_suffix"/>
	<xsl:param name="entity_class_name"/>
	<xsl:param name="entity_package"/>
	<xsl:param name="model_class_name"/>
	<xsl:param name="model_package"/>
	<xsl:param name="dtoSuffix"/>
	<xsl:param name="repository_package"/>
	<xsl:param name="repository_class_name"/>
	<xsl:param name="repositorySuffix"/>
	<xsl:param name="mapper_class_name"/>
	<xsl:param name="mapper_package"/>
	<xsl:param name="mapperSuffix"/>
	<xsl:param name="service_class_name"/>
	<xsl:param name="service_package"/>
	<xsl:param name="serviceSuffix"/>
	<xsl:param name="meta_class_name"/>
	<xsl:param name="meta_package"/>
	<xsl:param name="meta_suffix"/>
	<xsl:template match="/dataBaseStructure">package <xsl:value-of select="$controller_package"/>;
<xsl:variable name="meta" select="document('src/main/resources/templates/meta-info.xml')/meta-data/table[@name=$table]"/>
import io.swagger.v3.oas.annotations.tags.Tag;
import io.swagger.v3.oas.annotations.Parameter;
import io.swagger.v3.oas.annotations.Operation;
import io.swagger.v3.oas.annotations.responses.ApiResponse;
import io.swagger.v3.oas.annotations.responses.ApiResponses;
import lombok.extern.slf4j.Slf4j;
import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.http.HttpStatus;
import org.springframework.http.ResponseEntity;
import org.springframework.web.bind.annotation.*;
import org.springframework.validation.annotation.Validated;
import org.c3s.edgo.msdict.server.paginator.PaginatorData;
<xsl:if test="$meta/roles/controller">import org.springframework.security.access.prepost.PreAuthorize;
</xsl:if>
import <xsl:value-of select="$repository_package"/>.<xsl:value-of select="$repository_class_name"/>;
import <xsl:value-of select="$model_package"/>.<xsl:value-of select="$model_class_name"/>;
import <xsl:value-of select="$entity_package"/>.<xsl:value-of select="$entity_class_name"/>;
import <xsl:value-of select="$mapper_package"/>.<xsl:value-of select="$mapper_class_name"/>;
import <xsl:value-of select="$service_package"/>.<xsl:value-of select="$service_class_name"/>;
import <xsl:value-of select="$meta_package"/>.<xsl:value-of select="$meta_class_name"/>;

import java.util.List;
import java.util.Map;
import java.util.Optional;
import jakarta.validation.Valid;
import jakarta.validation.constraints.Min;

<xsl:for-each select="catalogs/entry/value/schemas/entry/value/tables/entry[key=$table]/value">
<xsl:variable name="mapping"><xsl:choose>
	<xsl:when test="count($meta/controller/mapping) = 0"><xsl:value-of select="@name"/></xsl:when>
	<xsl:otherwise><xsl:value-of select="$meta/controller/mapping/text()"/></xsl:otherwise>
</xsl:choose></xsl:variable>
<xsl:variable name="tag"><xsl:choose>
	<xsl:when test="string-length(@comment) = 0"><xsl:value-of select="@name"/></xsl:when>
	<xsl:otherwise><xsl:value-of select="@comment"/></xsl:otherwise>
</xsl:choose></xsl:variable>
@Slf4j
@RestController
@Validated
@Tag(name="<xsl:value-of select="$tag"/>", description="Работа с сущностью \"<xsl:value-of select="$tag"/>\"")
@RequestMapping("/api/v1/<xsl:value-of select="$mapping"/>")
public class <xsl:value-of select="@className"/><xsl:value-of select="$controller_suffix"/> {
	<xsl:variable name="primary" select="columns/entry/value[@isPrimaryKey = 'true']"/>
	private <xsl:value-of select="$service_class_name"/> service;
	@Autowired
	public <xsl:value-of select="@className"/><xsl:value-of select="$controller_suffix"/>(<xsl:value-of select="$service_class_name"/> service) {
		this.service = service;
	}
	<xsl:variable name="sort" select="$meta/sort/column"/><xsl:variable name="filter" select="$meta/filter/column"/>
	@GetMapping(value="")
	<xsl:if test="$meta/roles/controller[@type='list']">@PreAuthorize("hasAnyRole(<xsl:for-each select="$meta/roles/controller[@type='list']/role"><xsl:if
			test="position() != 1">, </xsl:if>'<xsl:value-of select="@name"/>'</xsl:for-each>)")</xsl:if>
	@Operation(summary = "Получить список сущностей \"<xsl:value-of select="$tag"/>\"")
	@ApiResponses(value = {
		@ApiResponse(responseCode = "200", useReturnTypeSchema = true)
	})
	public ResponseEntity&lt;PaginatorData&lt;<xsl:value-of select="$model_class_name"/>&gt;&gt; get<xsl:value-of select="@className"/>s(
			@Valid @RequestParam(defaultValue = "1") @Parameter(description="Номер страницы") @Min(1) int page,
			@Valid @RequestParam(defaultValue = "25") @Parameter(description="Элементов на странице") @Min(1) int size<xsl:if test="$sort">,
	    	@RequestParam(defaultValue = "") @Parameter(description="Сортировка по полю") String sort</xsl:if><xsl:if test="$filter">,
			@RequestParam(defaultValue = "") @Parameter(description="Фильтрация") Map&lt;String, String&gt; filter</xsl:if>) {
		return new ResponseEntity&lt;&gt;(service.get<xsl:value-of select="@className"/>sPaging(page-1, size<xsl:if test="$sort">, sort</xsl:if><xsl:if test="$filter">, filter</xsl:if>), HttpStatus.OK);
	}

	@GetMapping(value="/meta/")
	<xsl:if test="$meta/roles/controller[@type='meta']">@PreAuthorize("hasAnyRole(<xsl:for-each select="$meta/roles/controller[@type='meta']/role"><xsl:if
			test="position() != 1">, </xsl:if>'<xsl:value-of select="@name"/>'</xsl:for-each>)")</xsl:if>
	@Operation(summary = "Получить метаданные сущности \"<xsl:value-of select="$tag"/>\"")
	@ApiResponses(value = {
		@ApiResponse(responseCode = "200", useReturnTypeSchema = true)
	})
	public ResponseEntity&lt;<xsl:value-of select="$meta_class_name"/>&gt; get<xsl:value-of select="@className"/>Meta() {
		<xsl:value-of select="$meta_class_name"/> result = new <xsl:value-of select="$meta_class_name"/>();
		return new ResponseEntity&lt;&gt;(result, HttpStatus.OK);
	}

	@GetMapping(value="/<xsl:call-template name="pk_path"/>")
	<xsl:if test="$meta/roles/controller[@type='get']">@PreAuthorize("hasAnyRole(<xsl:for-each select="$meta/roles/controller[@type='get']/role"><xsl:if
			test="position() != 1">, </xsl:if>'<xsl:value-of select="@name"/>'</xsl:for-each>)")</xsl:if>
	@Operation(summary = "Получить запись сущности \"<xsl:value-of select="$tag"/>\" по ключу")
	@ApiResponses(value = {
		@ApiResponse(responseCode = "200", useReturnTypeSchema = true)
	})
	public ResponseEntity&lt;<xsl:value-of select="$model_class_name"/>&gt; get<xsl:value-of select="@className"/>ById(<xsl:call-template name="pk_parameters"/>) {
		<xsl:value-of select="$model_class_name"/> result = service.getById(<xsl:call-template name="pk_arguments"/>);
		return new ResponseEntity&lt;&gt;(result, HttpStatus.OK);
	}

	@PostMapping(value="")
	<xsl:if test="$meta/roles/controller[@type='post']">@PreAuthorize("hasAnyRole(<xsl:for-each select="$meta/roles/controller[@type='post']/role"><xsl:if
			test="position() != 1">, </xsl:if>'<xsl:value-of select="@name"/>'</xsl:for-each>)")</xsl:if>
	@Operation(summary = "Создать запись сущности \"<xsl:value-of select="$tag"/>\"")
	@ApiResponses(value = {
		@ApiResponse(responseCode = "200", useReturnTypeSchema = true)
	})
	public ResponseEntity&lt;<xsl:value-of select="$model_class_name"/>&gt; create<xsl:value-of select="@className"/>(@RequestBody <xsl:value-of select="$model_class_name"/> dto) {
		<xsl:value-of select="$model_class_name"/> result = service.create<xsl:value-of select="@className"/>(dto);
		return new ResponseEntity&lt;&gt;(result, HttpStatus.OK);
	}

	@PutMapping(value="/<xsl:call-template name="pk_path"/>")
	<xsl:if test="$meta/roles/controller[@type='put']">@PreAuthorize("hasAnyRole(<xsl:for-each select="$meta/roles/controller[@type='put']/role"><xsl:if
			test="position() != 1">, </xsl:if>'<xsl:value-of select="@name"/>'</xsl:for-each>)")</xsl:if>
	@Operation(summary = "Обновить запись сущности \"<xsl:value-of select="$tag"/>\" по ключу")
	@ApiResponses(value = {
		@ApiResponse(responseCode = "200", useReturnTypeSchema = true)
	})
	public ResponseEntity&lt;<xsl:value-of select="$model_class_name"/>&gt; update<xsl:value-of select="@className"/>(<xsl:call-template name="pk_parameters"/>, @RequestBody <xsl:value-of select="$model_class_name"/> dto) {
		<xsl:value-of select="$model_class_name"/> result = service.update<xsl:value-of select="@className"/>ById(<xsl:call-template name="pk_arguments"/>, dto);
		return new ResponseEntity&lt;&gt;(result, HttpStatus.OK);
	}

	@DeleteMapping(value="/<xsl:call-template name="pk_path"/>")
	<xsl:if test="$meta/roles/controller[@type='delete']">@PreAuthorize("hasAnyRole(<xsl:for-each select="$meta/roles/controller[@type='delete']/role"><xsl:if
			test="position() != 1">, </xsl:if>'<xsl:value-of select="@name"/>'</xsl:for-each>)")</xsl:if>
	@Operation(summary = "Удалить запись сущности \"<xsl:value-of select="$tag"/>\" по ключу")
	@ApiResponses(value = {
		@ApiResponse(responseCode = "200", useReturnTypeSchema = true)
	})
	public ResponseEntity&lt;<xsl:value-of select="$model_class_name"/>&gt; delete<xsl:value-of select="@className"/>ById(<xsl:call-template name="pk_parameters"/>) {
		service.delete<xsl:value-of select="@className"/>ById(<xsl:call-template name="pk_arguments"/>);
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
	<!--
    //
    //
    //
    -->
	<xsl:template name="pk_parameters"><xsl:for-each select="columns/entry/value[@isPrimaryKey = 'true']"><xsl:if test="position() != 1">, </xsl:if>@Valid @PathVariable("<xsl:value-of select="@name"/>") <xsl:value-of select="@shortType"/><xsl:text> </xsl:text><xsl:value-of select="@methodName"/></xsl:for-each>
	</xsl:template>
	<!--
    //
    //
    //
    -->
	<xsl:template name="pk_path"><xsl:for-each select="columns/entry/value[@isPrimaryKey = 'true']"><xsl:if test="position() != 1">/</xsl:if>{<xsl:value-of select="@name"/>}</xsl:for-each>
	</xsl:template>
	<!--
    //
    //
    //
    -->
	<xsl:template name="pk_arguments"><xsl:for-each select="columns/entry/value[@isPrimaryKey = 'true']"><xsl:if test="position() != 1">, </xsl:if><xsl:value-of select="@methodName"/></xsl:for-each>
	</xsl:template>

</xsl:stylesheet>