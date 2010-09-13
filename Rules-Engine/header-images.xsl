<xsl:stylesheet exclude-result-prefixes="hh" version="1.0"
    xmlns:hh="http://www.hannonhill.com/XSL/Functions" xmlns:xalan="http://xml.apache.org/xalan"
    xmlns:xsl="http://www.w3.org/1999/XSL/Transform" extension-element-prefixes="exsl"
    xmlns:exsl="http://exslt.org/common">

    <xsl:output method="html"/>

    <!-- Path of Calling Page -->
<xsl:variable name="path">
    <xsl:value-of select="system-index-block/calling-page/system-page/path"/>
</xsl:variable>

    <!-- Process rules, split any cases where there are more than one rule -->
    <xsl:variable name="rules">
        <system-index-block>
            <!-- process indexed files with the correct metadata attached -->
            <xsl:for-each select="//system-file/dynamic-metadata[name='rule']/..">
                <xsl:choose>
                    <!-- when there is more than one rule -->
                    <xsl:when test="contains(dynamic-metadata[name='rule']/value,';')">
                        <xsl:call-template name="split-rules">
                            <xsl:with-param name="name" select="display-name"/>
                            <xsl:with-param name="content" select="path"/>
                            <xsl:with-param name="rule" select="dynamic-metadata[name='rule']/value"
                            />
                        </xsl:call-template>
                    </xsl:when>
                    <xsl:otherwise>
                        <!-- Create new rules record to hold relevant bits -->
                        <system-page>
                            <name>
                                <xsl:value-of select="display-name"/>
                            </name>
                            <content>
                                <xsl:value-of select="path"/>
                            </content>
                            <rule>
                                <xsl:value-of select="dynamic-metadata[name='rule']/value"/>
                            </rule>
                            <xsl:call-template name="ruleType">
                                <xsl:with-param name="rule">
                                    <xsl:value-of select="dynamic-metadata[name='rule']/value"/>
                                </xsl:with-param>
                            </xsl:call-template>
                        </system-page>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </system-index-block>
    </xsl:variable>

    <!-- handle the splitting of rules -->
    <xsl:template name="split-rules">
        <xsl:param name="name"/>
        <xsl:param name="content"/>
        <xsl:param name="rule"/>
        <!-- Create record for first rule -->
        <system-page>
            <name>
                <xsl:value-of select="$name"/>
            </name>
            <content>
                <xsl:value-of select="$content"/>
            </content>
            <rule>
                <xsl:value-of select="substring-before($rule,';')"/>
            </rule>
            <xsl:call-template name="ruleType">
                <xsl:with-param name="rule">
                    <xsl:value-of select="substring-before($rule,';')"/>
                </xsl:with-param>
            </xsl:call-template>
        </system-page>
        <xsl:choose>
            <!-- If there aren't more we need to split off -->
            <xsl:when test="not(contains(substring-after($rule,';'),';'))">
                <!-- Create a record for the last rule -->
                <system-page>
                    <name>
                        <xsl:value-of select="$name"/>
                    </name>
                    <content>
                        <xsl:value-of select="$content"/>
                    </content>
                    <rule>
                        <xsl:value-of select="normalize-space(substring-after($rule,';'))"/>
                    </rule>
                    <xsl:call-template name="ruleType">
                        <xsl:with-param name="rule">
                            <xsl:value-of select="normalize-space(substring-after($rule,';'))"/>
                        </xsl:with-param>
                    </xsl:call-template>
                </system-page>
            </xsl:when>
            <xsl:otherwise>
                <!-- split out more rules -->
                <xsl:call-template name="split-rules">
                    <xsl:with-param name="name" select="$name"/>
                    <xsl:with-param name="content" select="$content"/>
                    <xsl:with-param name="rule" select="normalize-space(substring-after($rule,';'))"
                    />
                </xsl:call-template>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>

    <!-- assign a type to rules so they can be sorted -->
    <!-- Order of precedence: -->
    <!-- page specific, rules that don't end in '/' -->
    <!-- * rules for pages-->
    <!-- * rules for folders-->
    <!-- directory rules that end in '/' -->
    <xsl:template name="ruleType">
        <xsl:param name="rule"/>
        <type>
            <xsl:choose>
                <!-- assign variable folders to position three -->
                <xsl:when
                    test="contains($rule,'*') and substring(rule,string-length($rule),1) = '/'">
                    <xsl:text>3</xsl:text>
                </xsl:when>
                <!-- assign variable rules to position two -->
                <xsl:when test="contains($rule,'*')">
                    <xsl:text>2</xsl:text>
                </xsl:when>
                <!-- assign folder matches to position four -->
                <xsl:when test="substring($rule,string-length($rule),1) = '/'">
                    <xsl:text>4</xsl:text>
                </xsl:when>
                <!-- otherwise treat it as a page specific match and assign position one -->
                <xsl:otherwise>
                    <xsl:text>1</xsl:text>
                </xsl:otherwise>
            </xsl:choose>
        </type>
    </xsl:template>

    <!-- main template -->
    <xsl:template match="/">
        <!-- collect all the matches -->
        <xsl:variable name="matches">
            <xsl:for-each select="exsl:node-set($rules)/system-index-block/system-page">
                <xsl:sort select="type"/>
                <xsl:sort select="string-length(rule)" order="descending" data-type="number"/>
                <xsl:choose>
                    <xsl:when test="type = 1">
                        <xsl:if test="$path = rule">
                            <xsl:copy-of select="."/>
                        </xsl:if>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:variable name="glob">
                            <xsl:call-template name="match">
                                <xsl:with-param name="path" select="$path"/>
                                <xsl:with-param name="rule" select="rule"/>
                            </xsl:call-template>
                        </xsl:variable>
                        <xsl:if test="$glob = 'true'">
                            <xsl:copy-of select="."/>
                        </xsl:if>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:variable>

        <!-- use only the first match -->
        <p>
<img>
    <xsl:attribute name="alt">
        <xsl:value-of select="exsl:node-set($matches)/system-page[1]/name"/>
    </xsl:attribute>
                <xsl:attribute name="src">
                    <xsl:text>[system-asset]</xsl:text>
                    <xsl:value-of select="exsl:node-set($matches)/system-page[1]/content"/>
                    <xsl:text>[/system-asset]</xsl:text>
                </xsl:attribute>
                <xsl:attribute name="title">
                    <xsl:value-of select="exsl:node-set($matches)/system-page[1]/name"/>
                </xsl:attribute>
            </img>
        </p>
        <p class="hidden" id="printHeader">
            <xsl:value-of select="exsl:node-set($matches)/system-page[1]/name"/>
        </p>
    </xsl:template>

    <!-- function by which match can be called -->
    <xsl:template name="match">
        <xsl:param name="path"/>
        <xsl:param name="rule"/>
        <xsl:value-of select="hh:match(normalize-space($path), normalize-space(rule))"/>
    </xsl:template>

    <xalan:component functions="match" prefix="hh">
        <xalan:script lang="javascript">
            <![CDATA[
/*
 * Match
 * (c) 2009 Jason Aller <jraller@ucdavis.edu>
 * MIT license
 */

var match = function (path, rule) {
    var check = Boolean();
    pattern = new RegExp("^" + rule.replace("*", "(.)+", "g"), "i")
    return (path.match(pattern) != null) ? "true" : "";
};
			]]>
        </xalan:script>
    </xalan:component>


</xsl:stylesheet>
