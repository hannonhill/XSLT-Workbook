<!--
	Truncate String at Word Boundary
	Created by Ross Williams on 2010-04-20.

	USAGE
	_____
	In any XSLT Format:
	/BEGIN EXAMPLE/
	<xsl:stylesheet ...>
		...
		<xsl:include href="Path_To_truncate-string-by-words_XSLT_Format_Asset" />
		...
		
		<xsl:template match="system-page">
			... OTHER INFO ABOUT PAGE ...
			<h2>
				<xsl:call-template name="truncate-at-word">
					<xsl:with-param name="length" select="50" />
					<xsl:with-param name="string" select="title" />
				</xsl:call-template>
			</h2>
			...
		</xsl:template>
	</xsl:stylesheet>
	/END EXAMPLE/
-->
<xsl:stylesheet version="1.0" xmlns:str="http://exslt.org/strings" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
  
   <xsl:template name="truncate-at-word">
		<xsl:param name="length" select="140"/>
		<xsl:param name="string"/>
		<xsl:param name="tokens" select="'&#x9;&#xA;&#xD;&#x20;'" />
		
		<xsl:variable name="max" select="number($length)"/>
		<xsl:variable name="stringLength" select="string-length($string)" />
		<xsl:variable name="roughCut" select="substring($string, 1, $max)"/>
		<xsl:variable name="tokenized" select="str:tokenize($roughCut, $tokens)"/>
		
		<xsl:choose>
			<xsl:when test="$stringLength > $max">
				<xsl:for-each select="$tokenized[position() &lt; last()]">
					<xsl:value-of select="."/>
					<xsl:if test="position() != last()">
						<xsl:text> </xsl:text>
					</xsl:if>
				</xsl:for-each>
			</xsl:when>
			<xsl:otherwise>
				<xsl:value-of select="$string"/>
			</xsl:otherwise>
		</xsl:choose>
   </xsl:template>

</xsl:stylesheet>