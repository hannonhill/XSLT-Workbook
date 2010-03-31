<?xml version="1.0" encoding="UTF-8"?>
<!--
	Set body class from passthrough comment in <head>
	Created by Ross Williams on 2008-09-02.
	Copyright (c) 2008 Hannon Hill Corp. All rights reserved.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	<xsl:output encoding="UTF-8" indent="yes" method="xml"/>

	<xsl:variable name="head" select="/html/head"/>

	<!-- BEGIN XSLT pass-through copy templates -->
	<xsl:template match="/">
		<xsl:apply-templates />
	</xsl:template>
	
	<xsl:template match="@*|*" priority="-1">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="comment()">
		<xsl:copy-of select="."/>
	</xsl:template>

	<xsl:template match="text()">
		<xsl:value-of select="."/>
	</xsl:template>
	<!-- END XSLT pass-through copy templates -->
	
	<!--
		Specially copy the <body> tag to rewrite its @class attribute
	-->
	<xsl:template match="body" priority="1">
		<xsl:variable name="originalClass" select="string(@class)" />
		<xsl:copy>
			<!-- If there is a class set in the <head> comment or if there already was a class assigned to the <body> tag -->
			<xsl:if test="$head/comment()[starts-with(normalize-space(.),'body.class')] or $originalClass != ''">
				<!-- Create a new class attribute by combining the original class(es) and the classes from the <head> comment -->
				<xsl:attribute name="class"><xsl:value-of select="normalize-space(concat($originalClass,' ',substring-after($head/comment()[starts-with(normalize-space(.),'body.class')],'=')))"/></xsl:attribute>
			</xsl:if>
			<!-- Now, copy everything inside the body tag except the @class attribute -->
			<xsl:apply-templates select="@*[local-name() != 'class']|node()[local-name() != 'class']"/>
		</xsl:copy>
	</xsl:template>

</xsl:stylesheet>
