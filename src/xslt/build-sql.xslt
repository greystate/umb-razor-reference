<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE xsl:stylesheet [
	<!ENTITY newline "&#x0a;">
]>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

	<xsl:output method="text" indent="no" omit-xml-declaration="yes" />
	
	<xsl:variable name="props" select="/docset/members/property" />
	<xsl:variable name="funcs" select="/docset/members/function[not(@name = preceding-sibling::function/@name)]" />
	
	<xsl:template match="/">
		<xsl:apply-templates select="$props | $funcs" />
	</xsl:template>
	
	<xsl:template match="property | function">
		<xsl:if test="not(position() = 1)">
			<xsl:text>&newline;</xsl:text>
		</xsl:if>
		<xsl:text>INSERT OR IGNORE INTO searchIndex(name, type, path) VALUES ('</xsl:text>
			<xsl:value-of select="@name" />
			<xsl:text>', '</xsl:text>
			<xsl:value-of select="substring('Property|Function', not(self::property) * 9 + 1, 8)" />
			<xsl:text>', 'index.html#</xsl:text>
			<xsl:value-of select="@name" />
		<xsl:text>');</xsl:text>
	</xsl:template>
	
</xsl:stylesheet>