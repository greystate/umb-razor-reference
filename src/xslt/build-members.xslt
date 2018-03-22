<?xml version="1.0" encoding="utf-8" ?>
<!DOCTYPE xsl:stylesheet [
	<!ENTITY arrow "&#x21d2;">
]>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

	<xsl:output method="html" indent="yes" omit-xml-declaration="yes" />
	
	<xsl:attribute-set name="member-ids">
		<xsl:attribute name="class"><xsl:value-of select="name()" /></xsl:attribute>
		<xsl:attribute name="id"><xsl:value-of select="@name" /></xsl:attribute>
	</xsl:attribute-set>
	
	<xsl:key name="membersIndex" match="property | function" use="@name" />
	<xsl:key name="functionsIndex" match="function" use="@name" />
	<xsl:key name="propertiesIndex" match="property" use="@name" />

	<xsl:variable name="samples" select="document('codesamples.xml', /)/codesamples/example" />

	<xsl:template match="/">
		<xsl:apply-templates select="root/members" />
	</xsl:template>
	
	<xsl:template match="members">
		<h2><xsl:value-of select="@category" /></h2>
		<div class="memberlist">
			<xsl:for-each select="property | function[not(@name = preceding-sibling::function/@name)]">
				<xsl:sort select="@name" data-type="text" order="ascending" />
				<xsl:apply-templates select="." mode="group" />
			</xsl:for-each>
		</div>
	</xsl:template>
	
	<xsl:template match="function" mode="group">
		<xsl:variable name="overloads" select="key('functionsIndex', @name)" />
		
		<section xsl:use-attribute-sets="member-ids">
			<h2>
				<xsl:apply-templates select="@name" mode="link" />
			</h2>
			
			<div class="details">
				
				<div class="usage">
					<xsl:apply-templates select="$overloads" mode="usage">
						<xsl:sort select="count(argument)" data-type="number" order="ascending" />
					</xsl:apply-templates>
				</div>
				
				<xsl:apply-templates select="description" />
				
				<xsl:apply-templates select="$samples[@for = current()/@name]" />
				
				<xsl:apply-templates select="note" />
				
			</div>
		</section>
	</xsl:template>
	
	<xsl:template match="function" mode="usage">
		<div>
			<code>
				<xsl:value-of select="concat('.', @name, '(')" />
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
			<h2>
				<xsl:if test="$referenced"><xsl:attribute name="class">is-ref</xsl:attribute></xsl:if>
				<xsl:apply-templates select="@name" mode="link" />
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
				
				<xsl:apply-templates select="note" />
				
			</div>
		</section>
	</xsl:template>
	
	<xsl:template match="property[@ref] | function[@ref]" mode="group">
		<xsl:apply-templates select="key('membersIndex', @ref)[1]" mode="group">
			<xsl:with-param name="referenced" select="true()" />
		</xsl:apply-templates>
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

	<xsl:template match="description | note">
		<div class="{name()}">
			<xsl:apply-templates select="* | text()" mode="copy" />
		</div>
	</xsl:template>

	<xsl:template match="@name" mode="link">
		<a href="#{.}">
			<xsl:value-of select="." />
			<xsl:if test="parent::function">()</xsl:if>
		</a>
	</xsl:template>
	
	<xsl:template match="@type">
		<xsl:choose>
			<xsl:when test=". = 'boolean'">bool</xsl:when>
			<xsl:when test=". = 'datetime'">DateTime</xsl:when>
			<xsl:when test=". = 'integer'">int</xsl:when>
			<xsl:when test=". = 'collection'">IEnumerable</xsl:when>
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