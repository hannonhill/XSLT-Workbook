<?xml version="1.0" encoding="UTF-8"?>
<!--
	index-block-to-rss
	Updated by Ross Williams on 2009-02-26.
	Original author Unknown.
	Copyright (c) 2009 Hannon Hill Corp.
-->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:hh="http://www.hannonhill.com/XSL/Functions" xmlns:xalan="http://xml.apache.org/xalan" exclude-result-prefixes="hh" version="1.0">

	<!-- !!! DEPENDS ON: !!! -->
	<xsl:import href="xhtml2escapedHtml.xsl"/>
	<!-- 
	 USAGE
	 
	 Requires an Index Block with the "Append Calling Page Data" and
	 "Render Page XML" options enabled.
	 The current page will never be included in the RSS feed, in case th
	 *e Page
	 asset rendering the feed shares a parent folder with the actual feed items.
	 This stylesheet will use as a description a system-data-structure/summary
	 element that contains WYSIWYG XHTML and fall back to the summary metadata
	 field if the WYSIWYG is not found. Sorts by start date in descending order.
	 
	 You must correctly set the variables below.
	 To use this XSLT with Sites in Cascade 6.0+, set the site_path variable to
	 be empty (e.g. <xsl:variable name="site_path" />).
	 -->
	
	<!-- Maximum items returned -->
	<xsl:variable name="max_items">15</xsl:variable>
	<!-- URL prefix for news item links, no trailing slash -->
	<xsl:variable name="website_prefix">http://www.myorganization.com</xsl:variable>
	<!-- File extension used -->
	<xsl:variable name="file_extension">.html</xsl:variable>
	<!-- RSS extension to use -->
	<xsl:variable name="rss_extension">.rss</xsl:variable>
	<!-- Name of RSS generator -->
	<xsl:variable name="rss_generator">Cascade Server</xsl:variable>
	<!-- Web master's email address -->
	<xsl:variable name="web_master">webmaster@myorganization.com</xsl:variable>
	<!-- Path in the CMS: -->
	<!-- Empty if you are using Cascade Server 6+ Sites -->
	<xsl:variable name="site_path"/>
	<!-- Folder path to your site's root if you are using the Global Area -->
	<!-- <xsl:variable name="site_path">/MyOrg</xsl:variable> -->


	<!-- Match on the root index block -->
	<xsl:template match="/system-index-block">
		<rss version="2.0">
			<channel>
				<!-- write RSS header information -->
				<xsl:apply-templates mode="current" select="calling-page/system-page"/>
				<!-- write items, make sure pages have last-published-on element -->
				<xsl:apply-templates select="system-page[not(@current)] | system-folder//system-page[not(@current)]">
					<xsl:sort order="descending" select="start-date"/>
					<xsl:sort order="descending" select="last-published-on"/>
					<xsl:sort order="descending" select="created-on"/>
				</xsl:apply-templates>
			</channel>
		</rss>
	</xsl:template>
	
	<!-- Matches on the current system page, the news type page -->
	<xsl:template match="system-page" mode="current">
		<title>
			<xsl:value-of select="title"/>
		</title>
		<link>
			<xsl:value-of select="$website_prefix"/>
			<xsl:value-of select="substring-after(path,$site_path)"/>
			<xsl:value-of select="$rss_extension"/>
		</link>
		<description>
			<xsl:call-template name="choose-summary"/>
		</description>
		<pubDate>
			<xsl:call-template name="choose-date"/>
		</pubDate>
		<generator>
			<xsl:value-of select="$rss_generator"/>
		</generator>
		<webMaster>
			<xsl:value-of select="$web_master"/>
		</webMaster>
	</xsl:template>
	<!-- Match on first X individual news item pages -->
	<xsl:template match="system-page">
		<xsl:if test="position() &lt; number($max_items)">
			<item>
				<title>
					<xsl:value-of select="title"/>
				</title>
				<link>
					<xsl:value-of select="$website_prefix"/>
					<xsl:value-of select="substring-after(path,$site_path)"/>
					<xsl:value-of select="$file_extension"/>
				</link>
				<description>
					<xsl:call-template name="choose-summary"/>
				</description>
				<pubDate>
					<xsl:call-template name="choose-date"/>
				</pubDate>
				<guid><xsl:value-of select="$website_prefix"/>/<xsl:value-of select="@id"/></guid>
			</item>
		</xsl:if>
	</xsl:template>
	<xsl:template name="choose-summary">
		<xsl:choose>
			<xsl:when test="system-data-structure/summary/node()">
				<xsl:apply-templates select="system-data-structure/summary" mode="asHTML"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="summary"/>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	<xsl:template name="choose-date">
		<xsl:choose>
			<xsl:when test="last-published-on">
				<xsl:value-of select="hh:convertDate(number(last-published-on))"/>
			</xsl:when>
			<xsl:when test="start-date">
				<xsl:value-of select="hh:convertDate(number(start-date))"/>
			</xsl:when>
			<xsl:when test="created-on">
				<xsl:value-of select="hh:convertDate(number(created-on))"/>
			</xsl:when>
			<xsl:otherwise/>
		</xsl:choose>
	</xsl:template>
	
	<!-- Override link rewriting behavior of xhtml2escapedHtml for compatiblity with RSS 2.0 -->
	<xsl:template match="@href|@src" mode="xhtml2html"><xsl:text> </xsl:text><xsl:value-of select="local-name(.)"/>="<xsl:choose><xsl:when test="starts-with(.,$site_path)"><xsl:value-of select="concat($website_path,substring-after(.,$site_path))"/></xsl:when><xsl:otherwise>[system-asset]<xsl:value-of select="."/>[/system-asset]</xsl:otherwise></xsl:choose>"</xsl:template>
	
	
	<!-- Xalan component for date conversion from CMS date format to RSS 2.0 pubDate format -->
	<xalan:component functions="convertDate" prefix="hh">
		<xalan:script lang="javascript">
               function convertDate(date)
               {
                    var d = new Date(date);
                    // Splits date into components
                    var temp = d.toString().split(' ');
                    // timezone difference to GMT
                    var timezone = temp[5].substring(3);
                    // RSS 2.0 valid pubDate format
                    var retString = temp[0] + ', ' + temp[2] + ' ' + temp[1] + ' ' + temp[3] + ' ' + temp[4] + ' ' + timezone;
                    return retString;
              }
         </xalan:script>
	</xalan:component>
</xsl:stylesheet>
