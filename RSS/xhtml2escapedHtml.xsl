<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
<!-- 
	 USAGE
	 ________________________________________________________________________________________
	 <xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0">
	 
	 <xsl:include href="/path/to/this/format/xhtml2escapedHtml" />
	 
	 <xsl:template match="/something">
	 	<xsl:apply-templates select="path/to/element-containing-xhtml-nodes" mode="asHTML" />
	 </xsl:template>
	 OR
	 <xsl:template match="element-containing-xhtml-nodes">
	 	<xsl:call-template name="asHTML" />
	 </xsl:template>
	 
	 </xsl:stylesheet>
	 
-->
  <xsl:template match="*" mode="asHTML"><xsl:call-template name="asHTML"/></xsl:template>
  <xsl:template name="asHTML">
			<xsl:apply-templates mode="xhtml2html" />
  </xsl:template>
  <xsl:template match="img|br|hr|input|col|area|input|link|meta|param" mode="xhtml2html">
  	&lt;<xsl:value-of select="local-name(.)"/><xsl:apply-templates select="@*" mode="xhtml2html"/>&gt;<xsl:apply-templates mode="xhtml2html"/>

  </xsl:template>
  
  <xsl:template match="*" mode="xhtml2html">
  	&lt;<xsl:value-of select="local-name(.)"/><xsl:apply-templates select="@*" mode="xhtml2html"/>&gt;<xsl:apply-templates mode="xhtml2html"/>&lt;/<xsl:value-of select="local-name(.)"/>&gt;</xsl:template>

  <xsl:template match="@*" mode="xhtml2html">
  	<xsl:text> </xsl:text><xsl:value-of select="local-name(.)"/>="<xsl:value-of select="."/>"</xsl:template>

  <xsl:template match="@href|@src" mode="xhtml2html">
  	<xsl:text> </xsl:text><xsl:value-of select="local-name(.)"/>="[system-asset]<xsl:value-of select="."/>[/system-asset]"</xsl:template>
  	
  <!-- For RSS 2.0 compatibility, you'll want to override link rewriting behavior
       to use an absolute URI. The code below is an example, but won't work in this
       context, as the needed variables would be specific to a particular site's RSS,
		and should be defined in the XSLT that imports this stylesheet
		(using <xsl:import> to allow overriding imported templates)

  	   <xsl:template match="@href|@src" mode="xhtml2html">
  	     <xsl:text> </xsl:text><xsl:value-of select="local-name(.)"/>="<xsl:choose><xsl:when test="starts-with(.,$site_path)"><xsl:value-of select="substring-after(.,$site_path)"/></xsl:when><xsl:otherwise>[system-asset]<xsl:value-of select="."/>[/system-asset]</xsl:otherwise></xsl:choose>"</xsl:template>
  --> 
  	
  <xsl:template match="comment()" mode="xhtml2html">
  	<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>

  	<xsl:comment><xsl:value-of select="."/></xsl:comment>
  	<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>			
  </xsl:template>

  <xsl:template match="text()" mode="xhtml2html">
  	<xsl:choose>
  		<xsl:when test="contains(.,'&amp;') or contains(.,'&lt;')">
  			<xsl:text disable-output-escaping="yes">&lt;![CDATA[</xsl:text>
  			<xsl:value-of select="." />

  			<xsl:text disable-output-escaping="yes">]]&gt;</xsl:text>			
  		</xsl:when>
  		<xsl:otherwise>
  			<xsl:value-of select="."/>
  		</xsl:otherwise>
  	</xsl:choose>
  </xsl:template>
</xsl:stylesheet>