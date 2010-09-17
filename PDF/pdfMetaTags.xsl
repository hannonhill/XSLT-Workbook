<?xml version="1.0" encoding="UTF-8" ?>
<!--
	generate HTML meta tags for PDF output
	Created by Ross Williams on 2010-03-24.
	Copyright (c) 2010 Hannon Hill Corp. All rights reserved.
--><xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output encoding="UTF-8" indent="yes" method="xml"/>

	<xsl:template match="/system-index-block">
		<xsl:apply-templates select="calling-page/system-page/dynamic-metadata[starts-with(name,'pdf')]"/>
	</xsl:template>

	<xsl:template match="dynamic-metadata[name='pdfToc']">
		<meta name="generatePrintedPdfTableOfContents">
			<xsl:choose>
				<xsl:when test="value = 'Printed'">
					<xsl:attribute name="content">true</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="content">false</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</meta>
		<meta name="generatePdfTableOfContentsBookmarks">
			<xsl:choose>
				<xsl:when test="value = 'Embedded Bookmarks'">
					<xsl:attribute name="content">true</xsl:attribute>
				</xsl:when>
				<xsl:otherwise>
					<xsl:attribute name="content">false</xsl:attribute>
				</xsl:otherwise>
			</xsl:choose>
		</meta>
	</xsl:template>
	
	<xsl:template match="dynamic-metadata[name='pdfTocHeadings']">
		<meta name="pdfTableOfContentsHeadingLevels">
			<xsl:attribute name="content"><xsl:for-each select="value"><xsl:sort select="."/><xsl:value-of select="substring(.,2,1)"/><xsl:if test="position() != last()">,</xsl:if></xsl:for-each></xsl:attribute>
		</meta>
	</xsl:template>
	
	<xsl:template match="dynamic-metadata[name='pdfTocTitle']">
		<meta content="{value}" name="pdfTableOfContentsTitle"/>
	</xsl:template>
	
	<!-- Fall back and suppress anything else -->
	<xsl:template match="*"/>
		
</xsl:stylesheet>