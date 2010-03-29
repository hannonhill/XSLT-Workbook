<?xml version="1.0" encoding="UTF-8" ?>
<!--
	A-Z Index of Keywords
	Created by Ross Williams on 2009-03-12.
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                xmlns:str="http://exslt.org/strings"
                xmlns:set="http://exslt.org/sets"
                extension-element-prefixes="exsl str set">
	
	<xsl:variable name="lc">abcdefghijklmnopqrstuvwxyz</xsl:variable>
	<xsl:variable name="uc">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
	<!--
	 	Kicks off a series of templates (all in mode="decompose") that convert comma-separated, mixed-case keywords
		elements	into individual, lower-case keyword nodes:
		
		<keywords>important,useful, URGENT,Hannon Hill</keywords>
			BECOMES
		<keywords>
			<keyword>important</keyword>
			<keyword>useful</keyword>
			<keyword>urgent</keyword>
			<keyword>hannon hill</keyword>
		</keywords>
		
		Other elements are copied directly.
	-->
	<xsl:variable name="nodesDecomposed">
	  <xsl:apply-templates select="//system-page[string-length(keywords) > 0 and not(@reference)]" mode="decompose"/>
	</xsl:variable>
	
	<xsl:template match="@*|node()" mode="decompose" priority="-1">
		<xsl:copy>
			<xsl:apply-templates select="@*|node()" mode="decompose"/>
		</xsl:copy>
	</xsl:template>

	<xsl:template match="system-page" mode="decompose">
	  <xsl:copy>
	    <xsl:apply-templates select="@*|node()" mode="decompose"/>
	  </xsl:copy>
	</xsl:template>

	<xsl:template match="keywords" mode="decompose">
		<keywords>
	   <xsl:for-each select="str:tokenize(value,',')">
	     <keyword><xsl:value-of select="translate(normalize-space(.),$uc,$lc)" /></keyword>
	   </xsl:for-each>
	  </keywords>
	</xsl:template>
	<!-- End keyword decomposition -->
	
	<!-- 
		Takes the series of system-page elements with decomposed keywords and finds
		the unique keywords, storing one term element per unique keyword in the $allTerms
		variable, like so:
		<term letter="H">hannon hill</term>
		<term letter="I">important</term>
		<term letter="U">urgent</term>
		<term letter="U">useful</term>
	 -->
	<xsl:variable name="allTerms">
	  <xsl:for-each select="set:distinct(exsl:node-set($nodesDecomposed)//keyword)">
	    <xsl:sort select="." />
	    <term>
			  <xsl:variable name="candidateLetter" select="translate(substring(.,1,1),$lc,$uc)" />
			  <!-- Check whether it is really a letter, and... -->
			  <xsl:choose>
				<!-- ...if it really is a letter, output it. -->
			  	<xsl:when test="contains($uc,$candidateLetter)">
			  		<xsl:attribute name="letter"><xsl:value-of select="$candidateLetter"/></xsl:attribute>
			  	</xsl:when>
				<!-- ...if it isn't a letter, assign it a placeholder symbol. -->
				<xsl:otherwise>
					<xsl:attribute name="letter">#</xsl:attribute>
				</xsl:otherwise>
			  </xsl:choose>
	        <xsl:value-of select=""/>
        <xsl:value-of select="."/>
	    </term>
	  </xsl:for-each>
	</xsl:variable>
	
	<!-- 
		Takes the list of terms, generated above, and stores a letter element
		for each unique letter. This list is used to generate the navigation at
		the top of the terms list, ensuring that letters without terms are not included.
	 -->
	<xsl:variable name="termLetters">
	  <xsl:for-each select="set:distinct(exsl:node-set($allTerms)//@letter)">
	    <xsl:sort select="." />
	    <letter><xsl:value-of select="."/></letter>
	  </xsl:for-each>
	</xsl:variable>
	  
  <!-- 
		Now the actual generation of HTML for the A-Z index begins
 	-->
	<xsl:template match="/">
    <div id="site_index">
		<!-- First, loop through all the unique letters and make a navigation menu. -->
		<ul class="alpha_nav">
			<xsl:for-each select="exsl:node-set($termLetters)//letter">
	      	<li><xsl:value-of select="."/></li>
			</xsl:for-each>
		</ul>
		<!-- Then, loop through all the unique letters and... -->
      <xsl:for-each select="exsl:node-set($termLetters)//letter">
         <a name="letter-{.}" />
			<h2><xsl:value-of select="."/></h2>
          <dl>
				<!-- ...use <dt> and <dd> elements to display all the terms associated with that letter. -->
            <xsl:apply-templates select="exsl:node-set($allTerms)//term[@letter = current()]">
              <xsl:sort select="." />
            </xsl:apply-templates>
          </dl>
      </xsl:for-each>
    </div>
    <xsl:comment>END #site_index</xsl:comment>
  </xsl:template>
  
  <xsl:template match="term">
    <dt><xsl:value-of select="."/></dt>
	 <!-- For each term, display a <dd> element for each page that mentions the term in its <keywords> -->
    <xsl:apply-templates select="exsl:node-set($nodesDecomposed)//system-page[keywords/keyword = string(current())]" />
  </xsl:template>
  
  <xsl:template match="system-page">
    <dd>
      <a href="{path}">
        <xsl:choose>
          <xsl:when test="display-name">
            <xsl:value-of select="display-name"/>
          </xsl:when>
          <xsl:when test="title">
            <xsl:value-of select="title"/>
          </xsl:when>
          <xsl:otherwise>
            <xsl:value-of select="name"/>
          </xsl:otherwise>
        </xsl:choose>
      </a>
    </dd>
  </xsl:template>
  
</xsl:stylesheet>
