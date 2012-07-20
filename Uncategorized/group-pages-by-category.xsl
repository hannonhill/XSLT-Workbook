<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Group by Dynamic Category Metadata
	Created by Ross Williams on 2010-04-20.
	Copyright (c) 2010 Hannon Hill Corp. All rights reserved.
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
					 xmlns:exsl="http://exslt.org/common"
                xmlns:str="http://exslt.org/strings"
                xmlns:set="http://exslt.org/sets"
                extension-element-prefixes="exsl str set">
	
	<xsl:template match="/system-index-block">
		<xsl:variable name="categories" select="set:distinct(.//system-page/dynamic-metadata[name='category']/value)" />
		<p>All pages, listed by categories below.</p>
		<xsl:for-each select="$categories">
			<xsl:sort select="." />
			<xsl:if test=".//system-page[dynamic-metadata[name='category' and string(value) = string(current())]]">
				<h4><xsl:value-of select="."/></h4>
				<ul>
					<xsl:apply-templates select=".//system-page[dynamic-metadata[name='category' and string(value) = string(current())]]">
						<xsl:sort select="name" />
					</xsl:apply-templates>
				</ul>
			</xsl:if>
		</xsl:for-each>
	</xsl:template>
	
	<xsl:template match="system-page">
		<li>
			<a href="{path}">
				<xsl:value-of select="name"/>
			</a>
		</li>
	</xsl:template>
	
</xsl:stylesheet>
