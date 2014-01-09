<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
    <xsl:include href="/path/to/format-date"/>
    <xsl:variable name="domain">http://www.example.edu</xsl:variable>
    <xsl:variable name="tag">tag:www.example.edu,2013-12-01:</xsl:variable>
    <xsl:variable name="extension">.html</xsl:variable>
    <xsl:variable name="base">base-asset</xsl:variable>
    <xsl:variable name="format">yyyy-mm-dd'T'HH:MM:ss'Z'</xsl:variable>
    <xsl:template match="/system-index-block">
        <feed
            xmlns="http://www.w3.org/2005/Atom">
            <title>Example Feed</title>
            <link>
                <xsl:attribute name="href">
                    <xsl:value-of select="$domain"/>
                </xsl:attribute>
            </link>
            <updated>
                <xsl:call-template name="format-date">
                    <xsl:with-param name="date"/>
                    <xsl:with-param name="mask" select="$format"/>
                </xsl:call-template>
            </updated>
            <author>
                <name>Cascade Server</name>
            </author>
            <id>
                <xsl:value-of select="concat($tag,'x')"/>
            </id>
            <xsl:apply-templates select="system-page[start-date][not(contains(path,$base))]">
                <xsl:sort case-order="upper-first" data-type="number" lang="en" order="descending" select="start-date"/>
            </xsl:apply-templates>
        </feed>
    </xsl:template>
    <xsl:template match="system-page">
        <entry>
            <title>
                <xsl:value-of select="title"/>
            </title>
            <link>
                <xsl:attribute name="href">
                    <xsl:value-of select="concat($domain,path,$extension)"/>
                </xsl:attribute>
            </link>
            <id>
                <xsl:value-of select="concat($tag,@id)"/>
            </id>
            <updated>
                <xsl:call-template name="format-date">
                    <xsl:with-param name="date">
                        <xsl:value-of select="start-date"/>
                    </xsl:with-param>
                    <xsl:with-param name="mask" select="$format"/>
                </xsl:call-template>
            </updated>
            <summary>
                <xsl:variable name="short">
                    <xsl:call-template name="removeHtmlTags">
                        <xsl:with-param name="html" select="summary"/>
                    </xsl:call-template>
                </xsl:variable>
                <xsl:value-of select="normalize-space(substring($short, 0, 250))"/>
                <xsl:text>&#160;...</xsl:text>
            </summary>
        </entry>
    </xsl:template>
</xsl:stylesheet>