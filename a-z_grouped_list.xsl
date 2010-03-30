<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Alphabet Grouping
	Created by Ross Williams on 2009-06-18.
	Copyright (c) 2009 Hannon Hill Corp. All rights reserved.
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
                xmlns:exsl="http://exslt.org/common"
                xmlns:str="http://exslt.org/strings"
                exclude-result-prefixes="exsl str">

	<xsl:variable name="allUpperCase">ABCDEFGHIJKLMNOPQRSTUVWXYZ</xsl:variable>
	<xsl:variable name="allLowerCase">abcdefghijklmnopqrstuvwxyz</xsl:variable>
	
	<!--
		Groupings used in this script can be customized here. There can be only one
	 	<groupings> element. Each <group> element must have <letters>, which can be any
		Unicode characters and is case-insensitive for the standard English alphabet, and
		<title> which is used to head that group in the list.
	-->
	<xsl:variable name="groupings">
	  <groupings>
	     <group>
	        <letters>ABC</letters>
	        <title>A-C</title>
	     </group>
	     <group>
	        <letters>DEFG</letters>
	        <title>D-G</title>
	     </group>
	     <group>
	        <letters>HIJKL</letters>
	        <title>H-L</title>
	     </group>
	     <group>
	        <letters>MNO</letters>
	        <title>M-O</title>
	     </group>
	     <group>
	        <letters>PQR</letters>
	        <title>P-R</title>
	     </group>
	     <group>
	        <letters>STUVWXYZ</letters>
	        <title>S-Z</title>
	     </group>
	  </groupings>
	</xsl:variable>
	
	
	<xsl:template match="/">
		<!-- Calls template below to generate links for each group of letters -->
	   <xsl:call-template name="make-group-anchors"/>
	
		<!-- 
			Gathers all system-page elements in the index block into a variable.
		 	CHANGE THIS select clause if you want to be more or less picky about
			which assets you display in this grouping
		-->
	   <xsl:variable name="allPages" select="system-index-block//system-page" />
	   
		<!-- Now, iterate through each group in the $groupings variable... -->
		<xsl:for-each select="exsl:node-set($groupings)/groupings/group">
	      <xsl:sort select="title" />
	      
			<!--
				Make the <letters> element of the <group> into a $letters variable that is case-insensitive:
				<letters>AbC</letters>
					BECOMES
				$letters = 'AbCabcABC'
			-->
			<xsl:variable name="letters" select="concat(letters,translate(letters,$allUpperCase,$allLowerCase),translate(letters,$allLowerCase,$allUpperCase))" />
	      <xsl:comment>Processing letters: <xsl:value-of select="$letters"/></xsl:comment>
         <a name="{title}" />
			<!--
				xsl:if here checks whether there are pages in the $allPages group that
				have a title that begins with one of the letters in the current group.
				If so, we output a header and list of pages, sorted by title, that begin
				with those letters.
			 -->
	      <xsl:if test="count($allPages[starts-with(translate(title,$letters,str:padding(string-length($letters),'#')),'#')]) > 0">
	         <h3><xsl:value-of select="title"/></h3>
   	      <ul>
      	      <xsl:apply-templates select="$allPages[starts-with(translate(title,$letters,str:padding(string-length($letters),'#')),'#')]">
      	         <xsl:sort select="title" />
      	      </xsl:apply-templates>
            </ul>
	      </xsl:if>
	   </xsl:for-each>
		<!-- 
		 	Now we compile all of the <letters> elements into a single variable (allLettersRaw),
			make them case insensitive (allLetters), then output an "Other" group for any pages
			that start with symbols, numbers, etc. (anything not specified in a <letters> element)
		-->
	   <xsl:variable name="allLettersRaw" select="str:concat(exsl:node-set($groupings)/groupings/group/letters)"/>
	   <xsl:variable name="allLetters" select="concat($allLettersRaw,translate($allLettersRaw,$allUpperCase,$allLowerCase),translate($allLettersRaw,$allLowerCase,$allUpperCase))"/>
      <a name="other" />
	   <xsl:if test="count($allPages[not(starts-with(translate(title,$allLetters,str:padding(string-length($allLetters),'#')),'#'))]) > 0">
         <h3>Other</h3>
	      <ul>
   	      <xsl:apply-templates select="$allPages[not(starts-with(translate(title,$allLetters,str:padding(string-length($allLetters),'#')),'#'))]">
   	         <xsl:sort select="title" />
   	      </xsl:apply-templates>
         </ul>
      </xsl:if>
	</xsl:template>
	
	<xsl:template match="system-page">
	  <li>
   	  <a href="{path}">
   	     <xsl:value-of select="title"/>
   	  </a>
     </li>
	</xsl:template>
	
	<!-- Called from above, generates links for each grouping of letters -->
	<xsl:template name="make-group-anchors">
	   <xsl:for-each select="exsl:node-set($groupings)/groupings/group">
	      <a href="#{title}"><xsl:value-of select="title"/></a>&#160;
	   </xsl:for-each>
	   <a href="#other">Other</a>
	</xsl:template>
</xsl:stylesheet>