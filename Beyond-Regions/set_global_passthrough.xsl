<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Set comment from dynamic metadata
	(Should be attached to system-region in <head> element)
	Created by Ross Williams on 2008-09-02.
	Copyright (c) 2008 Hannon Hill Corp. All rights reserved.
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output encoding="UTF-8" indent="yes" method="xml" />

	<!--
		Find dynamic metadata with name = 'body-class' and pass it to
		the following template
	-->
	<xsl:template match="/system-index-block">
		<xsl:apply-templates select=".//system-folder[@current = 'true']/dynamic-metadata[name = 'body-class'][string-length(value) > 0]"/>
	</xsl:template>
	
	<!--
		Output a comment node for the dynamic metadata
	-->
	<xsl:template match="dynamic-metadata[name = 'body-class']">
		<xsl:comment>body.class = <xsl:value-of select="value"/></xsl:comment>
	</xsl:template>
	
</xsl:stylesheet>
