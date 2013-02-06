<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">

    <!-- Include to utilize the date formatter, see <lastmod> below -->
    <!--<xsl:include href="/path/to/format_date" />-->

    <!-- URL prefix for page locations, no trailing slash -->
    <xsl:variable name="website_prefix">http://www.myorganization.com</xsl:variable>
    
    <!-- Path in the CMS: -->
    <!-- Empty if you are using Cascade Server 6+ Sites -->
    <xsl:variable name="site_path"/>
    <!-- Folder path to your site's root if you are using the Global Area -->
    <!-- <xsl:variable name="site_path">/MyOrg</xsl:variable> -->

    <!-- File extension used -->
    <xsl:variable name="file_extension">.html</xsl:variable>

    <xsl:template match="system-index-block">
        <urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">
            <xsl:apply-templates select="//system-page" />
        </urlset>
    </xsl:template>

    <xsl:template match="system-page">
        <url> 
            <loc>
                <xsl:choose>
                    <xsl:when test="starts-with(path, $site_path)">
                        <xsl:value-of select="concat($website_prefix, substring-after(path, $site_path), $file_extension)" />
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:value-of select="concat($website_prefix, path, $file_extension)" />
                    </xsl:otherwise>
                </xsl:choose>                
            </loc>

            <!-- Un-comment to include last modified timestamp -->
            <!--<lastmod>
                    <xsl:call-template name="format-date">
                        <xsl:with-param name="date" select="last-modified" />
                        <xsl:with-param name="mask">isoDateTime</xsl:with-param>
                    </xsl:call-template>
            </lastmod>-->
        </url>
    </xsl:template>
    
</xsl:stylesheet>