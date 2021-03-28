<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE xsl:stylesheet [
	<!ENTITY arrow "&#x21d2;">
	<!ENTITY idChars "&lt;&gt;">
	<!ENTITY idReplaceChars "_">
]>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

	<xsl:output method="html" indent="yes" omit-xml-declaration="yes" />
	
	<xsl:attribute-set name="member-ids">
		<xsl:attribute name="class">
			<xsl:if test="@obsolete = 'yes'">obsolete </xsl:if>
			<xsl:value-of select="name()" />
			<xsl:if test="$samples[@for = current()/@name]"> has-example</xsl:if>
		</xsl:attribute>
		<xsl:attribute name="id"><xsl:value-of select="translate(@name, '&idChars;', '&idReplaceChars;')" /></xsl:attribute>
	</xsl:attribute-set>
	
	<xsl:key name="membersIndex" match="property | function" use="@name" />
	<xsl:key name="functionsIndex" match="function" use="@name" />
	<xsl:key name="propertiesIndex" match="property" use="@name" />

	<xsl:variable name="samples" select="document('codesamples.xml', /)/codesamples/example" />

	<xsl:template match="/">
		<xsl:apply-templates select="root/members" />
	</xsl:template>
	
	<xsl:template match="members">
		<section class="category">
			<header>
				<h2><xsl:value-of select="@category" /></h2>
				<xsl:apply-templates select="description" />
			</header>
			
			<div class="memberlist">
				<xsl:for-each select="property | function[not(@name = preceding-sibling::function/@name)]">
					<xsl:sort select="@name" data-type="text" order="ascending" />
					<xsl:apply-templates select="." mode="group" />
				</xsl:for-each>
			</div>
		</section>
	</xsl:template>
	
	<xsl:template match="function" mode="group">
		<xsl:variable name="overloads" select="key('functionsIndex', @name)" />
		
		<section xsl:use-attribute-sets="member-ids">
			<xsl:copy-of select="@id" />
			<h2>
				<xsl:apply-templates select="@name" mode="link" />
				<xsl:apply-templates select="self::*[@minVersion or @maxVersion]" mode="version" />
			</h2>
			
			<div class="details">
				
				<div class="usage">
					<xsl:apply-templates select="$overloads" mode="usage">
						<xsl:sort select="count(argument)" data-type="number" order="ascending" />
						<xsl:sort select="string-length(argument/@name)" data-type="number" order="ascending" />
					</xsl:apply-templates>
				</div>
				
				<xsl:apply-templates select="description" />
				
				<xsl:apply-templates select="$samples[@for = current()/@name]" />
				
				<xsl:apply-templates select="note" />
				
			</div>
		</section>
	</xsl:template>
	
	<xsl:template match="function" mode="usage">
		<xsl:variable name="object" select="ancestor::members/@staticObject" />
		<div>
			<code>
				<xsl:value-of select="concat($object, '.', @name, '(')" />
					<xsl:for-each select="argument">
						<xsl:apply-templates select="." />
						<xsl:if test="not(position() = last())">, </xsl:if>
					</xsl:for-each>
				<xsl:text>)</xsl:text>
			</code>
		
			<xsl:if test="@type">
				<xsl:text> &arrow; </xsl:text>
				<var><xsl:apply-templates select="@type" /></var>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template match="property" mode="group">
		<xsl:param name="referenced" select="false()" />
		<section xsl:use-attribute-sets="member-ids">
			<xsl:copy-of select="@id" />
			<h2>
				<xsl:if test="$referenced"><xsl:attribute name="class">is-ref</xsl:attribute></xsl:if>
				<xsl:apply-templates select="@name" mode="link" />
				<xsl:apply-templates select="self::*[@minVersion or @maxVersion]" mode="version" />
			</h2>
			
			<div class="details">
				
				<div class="usage">
					<code>
						<xsl:value-of select="concat('.', @name)" />
					</code>
					
					<xsl:if test="@type">
						<xsl:text> &arrow; </xsl:text>
						<var><xsl:apply-templates select="@type" /></var>
					</xsl:if>
				</div>
				
				<xsl:apply-templates select="description" />
				
				<xsl:apply-templates select="$samples[@for = current()/@name]" />
				
				<xsl:apply-templates select="note" />
				
			</div>
		</section>
	</xsl:template>
	
	<xsl:template match="property[@ref] | function[@ref]" mode="group">
		<xsl:apply-templates select="key('membersIndex', @ref)[1]" mode="group">
			<xsl:with-param name="referenced" select="true()" />
		</xsl:apply-templates>
	</xsl:template>
	
	<xsl:template match="property | function" mode="version">
		<data class="version-badge">
			<xsl:choose>
				<xsl:when test="@minVersion and @maxVersion">
					<xsl:attribute name="value"><xsl:value-of select="concat(@minVersion, '&#8212;', @maxVersion)" /></xsl:attribute>
					<xsl:value-of select="concat('v', @minVersion, '&#8212;v', @maxVersion)" />
				</xsl:when>
				<xsl:when test="@minVersion">
					<xsl:attribute name="value"><xsl:value-of select="@minVersion" /></xsl:attribute>
					<!-- Tag content -->
					<xsl:value-of select="concat('v', @minVersion, '+')" />
				</xsl:when>
				<xsl:when test="@maxVersion">
					<xsl:attribute name="value"><xsl:value-of select="@maxVersion" /></xsl:attribute>
					<xsl:value-of select="concat('v', @maxVersion)" />
				</xsl:when>
			</xsl:choose>
		</data>
	</xsl:template>
	
	<xsl:template match="argument">
		<xsl:apply-templates select="@type" />
		<xsl:text> </xsl:text>
		<var><xsl:value-of select="@name" /></var>
	</xsl:template>
	
	<xsl:template match="argument[@required = 'no']">
		<xsl:text>[</xsl:text>
		<xsl:apply-templates select="@type" />
		<xsl:text> </xsl:text>
		<var><xsl:value-of select="@name" /></var>
		<xsl:text>]</xsl:text>
	</xsl:template>

	<xsl:template match="argument[@type = 'params']" priority="1">
		<xsl:if test="@required = 'no'"> [</xsl:if>
		<var><xsl:value-of select="@name" /></var>
		<xsl:text>, </xsl:text>
		<var><xsl:value-of select="@name" /></var>
		<xsl:text> [, </xsl:text>
		<var><xsl:value-of select="@name" /> &#8230;</var>
		<xsl:text>]</xsl:text>
		<xsl:if test="@required = 'no'">]</xsl:if>
	</xsl:template>

	<xsl:template match="description | note">
		<div class="{normalize-space(concat(@type, ' ', name()))}">
			<xsl:apply-templates select="* | text()" mode="copy" />
		</div>
	</xsl:template>
	
	<xsl:template match="description[not(p)] | note[not(p)]">
		<div class="{normalize-space(concat(@type, ' ', name()))}">
			<p>
				<xsl:apply-templates select="* | text()" mode="copy" />
			</p>
		</div>
	</xsl:template>
	
	<xsl:template match="@name" mode="link">
		<a href="#{translate(., '&idChars;', '&idReplaceChars;')}">
			<xsl:if test="../@id"><xsl:attribute name="href"><xsl:value-of select="concat('#', ../@id)" /></xsl:attribute></xsl:if>
			<xsl:value-of select="." />
			<xsl:if test="parent::function">()</xsl:if>
		</a>
	</xsl:template>
	
	<xsl:template match="@type">
		<xsl:choose>
			<xsl:when test=". = 'boolean'">bool</xsl:when>
			<xsl:when test=". = 'datetime'">DateTime</xsl:when>
			<xsl:when test=". = 'integer'">int</xsl:when>
			<xsl:otherwise><xsl:value-of select="." /></xsl:otherwise>
		</xsl:choose>
	</xsl:template>

	<!-- Identity transform -->
	<xsl:template match="* | text()" mode="copy">
		<xsl:copy>
			<xsl:copy-of select="@*" />
			<xsl:apply-templates select="* | text()" mode="copy" />
		</xsl:copy>
	</xsl:template>
	
	<xsl:template match="ref" mode="copy">
		<xsl:variable name="id">
			<xsl:if test="@id"><xsl:value-of select="@id" /></xsl:if>
			<xsl:if test="not(@id)"><xsl:value-of select="." /></xsl:if>
		</xsl:variable>
		<a class="ref" href="#{$id}">
			<xsl:value-of select="." />
			<xsl:if test="key('functionsIndex', $id)">()</xsl:if>
		</a>
	</xsl:template>
	
	<!-- Code sample templates -->
	<xsl:template match="example">
		<div class="example language-csharp">
			<xsl:if test="@lang"><xsl:attribute name="class"><xsl:value-of select="concat('example language-', @lang)" /></xsl:attribute></xsl:if>
			<h3>Example</h3>
			<pre>
				<code>
					<xsl:apply-templates mode="copy" />
				</code>
			</pre>
		</div>
	</xsl:template>
	
	<xsl:template match="example[code or pre]">
		<div class="example language-csharp">
			<xsl:if test="@lang"><xsl:attribute name="class"><xsl:value-of select="concat('example language-', @lang)" /></xsl:attribute></xsl:if>
			<h3>Example</h3>
			<xsl:apply-templates mode="copy" />
		</div>
	</xsl:template>

</xsl:stylesheet>
