<xsl:stylesheet
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:include href="/path/to/format-date"/>
    <xsl:variable name="domain">http://www.example.edu</xsl:variable>
    <xsl:variable name="extension">.html</xsl:variable>
    <xsl:variable name="base">base-asset</xsl:variable>
    <xsl:variable name="format">ddd, dd mmm yyyy HH:MM:ss Z</xsl:variable>
    <xsl:template match="/system-index-block">
        <rss version="2.0">
            <channel>
                <title>Example Feed</title>
                <link>
                    <xsl:value-of select="$domain"/>
                </link>
                <description>The latest news for the site.</description>
                <language>en-us</language>
                <pubDate>
                    <xsl:call-template name="format-date">
                        <xsl:with-param name="date"/>
                        <xsl:with-param name="mask" select="$format"/>
                    </xsl:call-template>
                </pubDate>
                <generator>Cascade Server</generator>
                <webMaster>webmaster@example.edu (Webmaster)</webMaster>
                <xsl:apply-templates select="system-page[start-date][not(contains(path,$base))]">
                    <xsl:sort case-order="upper-first" data-type="number" lang="en" order="descending" select="start-date"/>
                </xsl:apply-templates>
            </channel>
        </rss>
    </xsl:template>
    <xsl:template match="system-page">
        <item>
            <title>
                <xsl:value-of select="title"/>
            </title>
            <link>
                <xsl:value-of select="concat($domain,path,$extension)"/>
            </link>
            <description>
                <xsl:variable name="short">
                    <xsl:call-template name="removeHtmlTags">
                        <xsl:with-param name="html" select="summary"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="normalize-space(substring($short, 0, 250))"/>
                <xsl:text>&#160;...</xsl:text>
            </description>
            <pubDate>
                <xsl:call-template name="format-date">
                    <xsl:with-param name="date">
                        <xsl:value-of select="start-date"/>
                    </xsl:with-param>
                    <xsl:with-param name="mask" select="$format"/>
                </xsl:call-template>
            </pubDate>
            <guid>
                <xsl:value-of select="concat($domain,path,$extension)"/>
            </guid>
        </item>
    </xsl:template>
    <xsl:template name="removeHtmlTags">
        <xsl:param name="html"/>
        <xsl:choose>
            <xsl:when test="contains($html, '&lt;')">
                <xsl:value-of select="substring-before($html, '&lt;')"/>
                <xsl:call-template name="removeHtmlTags">
                    <xsl:with-param name="html" select="substring-after($html, '&gt;')"/>
                </xsl:call-template>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$html"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
</xsl:stylesheet>