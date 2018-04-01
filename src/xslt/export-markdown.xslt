<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE xsl:stylesheet [
	<!ENTITY TAB "&#x09;">
	<!ENTITY LF "&#x0A;">
]>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

	<xsl:output method="text" indent="no" omit-xml-declaration="yes" />

	<xsl:strip-space elements="*" />
	<xsl:variable name="samples" select="document('codesamples.xml', /)/codesamples/example" />
	
	<xsl:param name="category" select="'IPublishedContent'" />
	
	<xsl:template match="/">
		<xsl:apply-templates select="docset/members[starts-with(@category, $category)]" />
	</xsl:template>

	<xsl:template match="members" xml:space="preserve">
<xsl:value-of select="concat('# ', @category)" />

<xsl:apply-templates select="description" mode="markdown" />

<xsl:text>## Properties</xsl:text>

<xsl:apply-templates select="property" />

<xsl:text>## Functions</xsl:text>

<xsl:apply-templates select="function" />
	</xsl:template>

	<xsl:template match="property" xml:space="preserve">
<xsl:apply-templates select="@name" mode="markdown" />

<xsl:apply-templates select="description" mode="markdown" />

<xsl:apply-templates select="$samples[@for = current()/@name]" mode="markdown-gfm" />
	</xsl:template>
	
	<xsl:template match="function" xml:space="preserve">
<xsl:apply-templates select="@name" mode="markdown" />

<xsl:apply-templates select="description" mode="markdown" />

<xsl:apply-templates select="$samples[@for = current()/@name]" mode="markdown-gfm" />
	</xsl:template>
	

<!-- Markdown renderers -->
	<xsl:template match="text()" mode="markdown" priority="-1">
<xsl:value-of select="normalize-space()" />
	</xsl:template>
	
	<xsl:template match="strong" mode="markdown">
<xsl:value-of select="concat(' **', ., '** ')" />
	</xsl:template>
	
	<xsl:template match="@name" mode="markdown">
<xsl:value-of select="concat('### ', .)" />
<xsl:if test="parent::function">
<xsl:text>(</xsl:text>
	<xsl:for-each select="../argument">
		<xsl:value-of select="@type" />
		<xsl:if test="not(position() = last())">, </xsl:if>
	</xsl:for-each>
<xsl:text>)</xsl:text>
</xsl:if>
	</xsl:template>

	<xsl:template match="p[preceding-sibling::*[1][self::p]]" mode="markdown">
<xsl:text>&LF;&LF;</xsl:text>
<xsl:apply-templates mode="markdown" />
	</xsl:template>
	
	<xsl:template match="code | var" mode="markdown">
<xsl:value-of select="concat(' `', ., '` ')" />
	</xsl:template>
	
	<xsl:template match="example" mode="markdown">
<xsl:text>&TAB;</xsl:text>
<xsl:value-of select="." />
<xsl:text>&LF;</xsl:text>
	</xsl:template>

	<xsl:template match="example" mode="markdown-gfm">
<xsl:text>```</xsl:text>
<xsl:value-of select="." />
<xsl:text>```</xsl:text>
	</xsl:template>
</xsl:stylesheet>
