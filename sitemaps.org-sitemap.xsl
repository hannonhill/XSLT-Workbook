<?xml version="1.0" encoding="UTF-8" ?>
<!--
	XML Sitemap Generator (sitemaps.org AKA Google Sitemap)
	Created by Ross Williams on 2009-03-12.
	Copyright (c) 2009 Hannon Hill Corp. All rights reserved.
	
	USAGE:
	
	Create an index block of whatever folder you would like to generate
	a sitemap for; ensure the index block returns 'Regular Content,' 'User Metadata,'
	and 'System Metadata.' Apply the index block and this XSL Format to
	the default region of a template that contains only one line:
	<system-region name="DEFAULT" />
	The template should be output as XML with a .xml file extension.
	
	You can enhance the functionality of sitemap generation by adding one or
	two pieces of Dynamic Metadata to your Folders and Pages:
	
	identifier				purpose							possible values
	----------				-------							---------------
	exclude-sitemaps		Prevent a page from			'Exclude', 'Include'
								displaying in your      
								Sitemap XML.            
                                                
	sitemap-changefreq	Include a <changefreq>		'always', 'hourly',
								element for this page		'daily', 'weekly',
								in the Sitemap XML that		'monthly', 'yearly'
								informs search engines		'never'
								of how often you expect		(documented on sitemaps.org)
								to update the page.
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	
	<xsl:include href="format-date.xsl" />

  <!-- URL prefix for page links, no trailing slash -->
  <xsl:variable name="website_prefix">http://www.mycompany.com</xsl:variable>
  <!-- File extension used on published pages -->
  <xsl:variable name="file_extension">.html</xsl:variable>
  <!-- Path in the CMS, no trailing slash -->
  <xsl:variable name="site_path">/mycompany.com</xsl:variable>

	<xsl:template match="/system-index-block">
	  <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
	    <xsl:apply-templates select=".//system-page[not(dynamic-metadata[name='exclude-sitemaps' and value='Exclude']) and last-published-on]">
	    	<xsl:sort select="last-published-on" data-type="number" order="descending" />
	    </xsl:apply-templates>
	  </urlset>
	</xsl:template>
	
	<xsl:template match="system-page">
	  <url>
	    <loc>
        <xsl:value-of select="$website_prefix"/>
        <xsl:value-of select="substring-after(path,$site_path)"/>
        <xsl:value-of select="$file_extension"/>
	    </loc>
	    <lastmod>
	      <xsl:call-template name="format-date">
	        <xsl:with-param name="date" select="last-published-on" />
	        <xsl:with-param name="mask">isoUtcDateTime</xsl:with-param>
	      </xsl:call-template>
	    </lastmod>
		 <xsl:if test="ancestor-or-self::*/dynamic-metadata[name='sitemap-changefreq' and value != '']">
			<changefreq>
				<xsl:value-of select="(ancestor-or-self::*/dynamic-metadata[name='sitemap-changefreq' and value != ''])[position() = last()]/value"/>
			</changefreq>
		 </xsl:if>
	  </url>
	</xsl:template>
</xsl:stylesheet>
