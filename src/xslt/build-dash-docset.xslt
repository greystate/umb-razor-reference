<?xml version="1.0" encoding="utf-8" ?>
<xsl:stylesheet
	version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
>

	<xsl:output method="html"
		indent="yes"
		omit-xml-declaration="yes"
		doctype-system="about:legacy-compat"
	/>

	<xsl:include href="build-members.xslt" />

	<!-- Override root template -->
	<xsl:template match="/">
		<html>
		<head>
			<title>
				<xsl:text>Umbraco Razor Quick Reference</xsl:text>
				<xsl:value-of select="concat(' &#8212; v', docset/@version)" />
			</title>
			<link rel="stylesheet" href="app.css" />
			<link rel="stylesheet" href="https://use.typekit.net/vax3dgg.css" />
			<script src="app.min.js"></script>
			<meta name="viewport" content="width=device-width, initial-scale=1" />
			<xsl:comment>
Note: This file is generated by XSLT from the razor-reference.xml file.
So you definitely shouldn't be editing it, or you'll end up sad...
			</xsl:comment>
		</head>
		<body id="toc">
			
			<main id="ref">
				<header class="masthead">
					<h1><xsl:value-of select="docset/name" /></h1>
					<div class="description">
						<xsl:apply-templates select="docset/description" mode="copy" />
						
						<xsl:call-template name="feed-link" />
					</div>
				</header>
				
				<xsl:apply-templates select="docset/members" />
			</main>
			
			<xsl:call-template name="fork-banner" />
			<!-- <xsl:call-template name="toc-link" /> -->
		</body>
		</html>
	</xsl:template>

	<xsl:template name="fork-banner">
		<a href="https://github.com/greystate/umb-razor-reference#readme">
			<img class="forkme"
				src="https://s3.amazonaws.com/github/ribbons/forkme_right_orange_ff7600.png"
				alt="Fork me on GitHub"
			/>
		</a>
	</xsl:template>
	
	<xsl:template name="feed-link">
		<a class="feed" href="dash-feed://http%3A%2F%2Fgreystate.dk%2Fresources%2Fumbraco%2Frazor-reference%2Fumbraco-razor-quick-reference.xml" title="Subscribe to feed for Dash here">Dash Feed</a>
	</xsl:template>

</xsl:stylesheet>
