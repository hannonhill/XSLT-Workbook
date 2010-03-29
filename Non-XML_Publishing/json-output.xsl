<xsl:stylesheet version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

	<xsl:template match="/system-index-block">
		<!--
			Must be NO WHITESPACE between <xsl:comment> and #START-ROOT-CODE,
			same for #END-ROOT-CODE and </xsl:comment>
		-->
		<xsl:comment>#START-ROOT-CODE
			<xsl:text>({</xsl:text>
			<xsl:text>"items": [</xsl:text>
			<xsl:apply-templates select="//system-page" />
			<xsl:text>]</xsl:text>
			<xsl:text>, "bogus": "</xsl:text>
		#END-ROOT-CODE</xsl:comment>
	</xsl:template>

	<!--
		Simple example to output {"name": "system-name", "title": "Title
		Metadata"}
	-->
	<xsl:template match="system-page">
		<xsl:text>{"name": "</xsl:text>
		<xsl:value-of select="name" />
		<xsl:text>", "title": "</xsl:text>
		<xsl:value-of select="title" />
		<xsl:text>"}</xsl:text>
		<xsl:if test="position() != last()">
			<xsl:text>, </xsl:text>
		</xsl:if>
	</xsl:template>

</xsl:stylesheet>