<xsl:stylesheet version="1.0" xmlns:fo="http://www.w3.org/1999/XSL/Format" xmlns:html="http://www.w3.org/1999/xhtml" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">
<xsl:output encoding="utf-8" indent="yes" method="xml" version="1.0"/>
 
<!--======================================================================
       Parameters
 
=======================================================================-->
	<!-- Instance-specific parameters -->
	<xsl:param name="serverURL">http://www.myorganization.com/</xsl:param>
	<xsl:param name="pixelsPerInch">72</xsl:param>
	<!-- Must be true() or false() [no quotes] -->
	<xsl:param name="fitToPageWidth" select="true()" />
	
	<!-- Table of Contents -->
	<!-- <xsl:variable name="discoveredMeta">
			<xsl:for-each select="/html/head/meta | /html:html/html:head/html:meta">
				<xsl:for-each select="@* | @html:*">
					@<xsl:value-of select="name()"/> = <xsl:value-of select="."/><xsl:if test="position() != last()">, </xsl:if>
				</xsl:for-each>
				<xsl:if test="position() != last()">;
				</xsl:if>
			</xsl:for-each>
		</xsl:variable> --><!-- DEBUG -->
	<xsl:param name="includeTocPrinted" select="/html/head/meta[@name='generatePrintedPdfTableOfContents']/@content = 'true' or /html:html/html:head/html:meta[@name='generatePrintedPdfTableOfContents']/@content = 'true'"/>
	<xsl:param name="includeTocBookmarks" select="/html/head/meta[@name='generatePdfTableOfContentsBookmarks']/@content = 'true' or /html:html/html:head/html:meta[@name='generatePdfTableOfContentsBookmarks']/@content = 'true'"/>
	<xsl:param name="tocHeadingLevels" select="concat(translate(/html/head/meta[@name='pdfTableOfContentsHeadingLevels']/@content,',',''), translate(/html:html/html:head/html:meta[@name='pdfTableOfContentsHeadingLevels']/@content,',',''))"/>
	<xsl:param name="tocTitle" select="concat(/html/head/meta[@name='pdfTableOfContentsTitle']/@content,/html:html/html:head/html:meta[@name='pdfTableOfContentsTitle']/@content)"/>
	<xsl:param name="pageOrientation" select="concat(/html/head/meta[@name='pdfPageOrientation']/@content,/html:html/html:head/html:meta[@name='pdfPageOrientation']/@content)"/>
	<xsl:param name="pageSize" select="concat(/html/head/meta[@name='pdfPageSize']/@content,/html:html/html:head/html:meta[@name='pdfPageSize']/@content)"/>
   <!-- page size -->
	<xsl:param name="page-width">
		<xsl:choose>
			<xsl:when test="$pageOrientation = 'Portrait' and $pageSize = 'Letter'">8.5in</xsl:when>
			<xsl:when test="$pageOrientation = 'Landscape' and $pageSize = 'Letter'">11in</xsl:when>
			<xsl:when test="$pageOrientation = 'Portrait' and $pageSize = 'Legal'">8.5in</xsl:when>
			<xsl:when test="$pageOrientation = 'Landscape' and $pageSize = 'Legal'">14in</xsl:when>
			<xsl:otherwise>8.5in</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
	<xsl:param name="page-height">
		<xsl:choose>
			<xsl:when test="$pageOrientation = 'Portrait' and $pageSize = 'Letter'">11in</xsl:when>
			<xsl:when test="$pageOrientation = 'Landscape' and $pageSize = 'Letter'">8.5in</xsl:when>
			<xsl:when test="$pageOrientation = 'Portrait' and $pageSize = 'Legal'">14in</xsl:when>
			<xsl:when test="$pageOrientation = 'Landscape' and $pageSize = 'Legal'">8.5in</xsl:when>
			<xsl:otherwise>11in</xsl:otherwise>
		</xsl:choose>
	</xsl:param>
   <!-- page margins -->
   <xsl:param name="page-margin-top">.5in</xsl:param>
   <xsl:param name="page-margin-bottom">.5in</xsl:param>
   <xsl:param name="page-margin-left">1in</xsl:param>
   <xsl:param name="page-margin-right">1in</xsl:param>
   <!-- page header and footer -->
   <xsl:param name="page-header-margin">0.4in</xsl:param>
   <xsl:param name="page-footer-margin">0.4in</xsl:param>
   <xsl:param name="title-print-in-header">false</xsl:param>
   <xsl:param name="page-number-print-in-footer">true</xsl:param>
   <!-- multi column -->
   <xsl:param name="column-count">1</xsl:param>
   <xsl:param name="column-gap">12pt</xsl:param>
   <!-- writing-mode: lr-tb | rl-tb | tb-rl -->
   <xsl:param name="writing-mode">lr-tb</xsl:param>
   <!-- text-align: justify | start -->
   <xsl:param name="text-align">start</xsl:param>
   <!-- hyphenate: true | false -->
   <xsl:param name="hyphenate">false</xsl:param>
 
<!--======================================================================
       Attribute Sets
 
=======================================================================-->
   <!--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        Root
   =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-->
   <xsl:attribute-set name="root">
     <xsl:attribute name="writing-mode"><xsl:value-of select="$writing-mode"/></xsl:attribute>
     <xsl:attribute name="hyphenate"><xsl:value-of select="$hyphenate"/></xsl:attribute>
     <xsl:attribute name="text-align"><xsl:value-of select="$text-align"/></xsl:attribute>
     <!-- specified on fo:root to change the properties' initial values -->
   </xsl:attribute-set>
   <xsl:attribute-set name="page">
     <xsl:attribute name="page-width"><xsl:value-of select="$page-width"/></xsl:attribute>
     <xsl:attribute name="page-height"><xsl:value-of select="$page-height"/></xsl:attribute>
     <!-- specified on fo:simple-page-master -->
   </xsl:attribute-set>
   <xsl:attribute-set name="body">
		<xsl:attribute name="font-size"><xsl:call-template name="pxTopt"><xsl:with-param name="px" select="12"/></xsl:call-template></xsl:attribute>
     <!-- specified on fo:flow's only child fo:block -->
   </xsl:attribute-set>
   <xsl:attribute-set name="page-header">
     <!-- specified on (page-header)fo:static-content's only child
fo:block -->
     <xsl:attribute name="font-size">small</xsl:attribute>
     <xsl:attribute name="text-align">center</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="page-footer">
     <!-- specified on (page-footer)fo:static-content's only child
fo:block -->
     <xsl:attribute name="font-size">small</xsl:attribute>
     <xsl:attribute name="text-align">center</xsl:attribute>
   </xsl:attribute-set>
   <!--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        Block-level
   =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-->
   <xsl:attribute-set name="h1">
     <xsl:attribute name="font-size">2em</xsl:attribute>
     <xsl:attribute name="font-weight">bold</xsl:attribute>
     <xsl:attribute name="space-before">0.5em</xsl:attribute>
     <xsl:attribute name="space-after">0.5em</xsl:attribute>
     <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
     <xsl:attribute name="keep-together.within-column">always</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="h2">
     <xsl:attribute name="font-size">1.5em</xsl:attribute>
     <xsl:attribute name="font-weight">bold</xsl:attribute>
     <xsl:attribute name="space-before">0.5em</xsl:attribute>
     <xsl:attribute name="space-after">0.5em</xsl:attribute>
     <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
     <xsl:attribute name="keep-together.within-column">always</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="h3">
     <xsl:attribute name="font-size">1.17em</xsl:attribute>
     <xsl:attribute name="font-weight">bold</xsl:attribute>
     <xsl:attribute name="space-before">1em</xsl:attribute>
     <xsl:attribute name="space-after">1em</xsl:attribute>
     <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
     <xsl:attribute name="keep-together.within-column">always</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="h4">
     <xsl:attribute name="font-size">1em</xsl:attribute>
     <xsl:attribute name="font-weight">bold</xsl:attribute>
     <xsl:attribute name="space-before">1.17em</xsl:attribute>
     <xsl:attribute name="space-after">1.17em</xsl:attribute>
     <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
     <xsl:attribute name="keep-together.within-column">always</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="h5">
     <xsl:attribute name="font-size">0.83em</xsl:attribute>
     <xsl:attribute name="font-weight">bold</xsl:attribute>
     <xsl:attribute name="space-before">1.33em</xsl:attribute>
     <xsl:attribute name="space-after">1.33em</xsl:attribute>
     <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
     <xsl:attribute name="keep-together.within-column">always</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="h6">
     <xsl:attribute name="font-size">0.67em</xsl:attribute>
     <xsl:attribute name="font-weight">bold</xsl:attribute>
     <xsl:attribute name="space-before">1.67em</xsl:attribute>
     <xsl:attribute name="space-after">1.67em</xsl:attribute>
     <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
     <xsl:attribute name="keep-together.within-column">always</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="p">
     <xsl:attribute name="space-before">.4em</xsl:attribute>
     <xsl:attribute name="space-after">.4em</xsl:attribute>
     <!-- e.g.,
     <xsl:attribute name="text-indent">1em</xsl:attribute>
     -->
   </xsl:attribute-set>
   <xsl:attribute-set name="p-initial" use-attribute-sets="p">
     <!-- initial paragraph, preceded by h1..6 or div -->
     <!-- e.g.,
     <xsl:attribute name="text-indent">0em</xsl:attribute>
     -->
   </xsl:attribute-set>
   <xsl:attribute-set name="p-initial-first" use-attribute-sets="p-initial">
     <!-- initial paragraph, first child of div, body or td -->
   </xsl:attribute-set>
   <xsl:attribute-set name="blockquote">
     <xsl:attribute name="start-indent">inherited-property-value(start-indent) +
24pt</xsl:attribute>
     <xsl:attribute name="end-indent">inherited-property-value(end-indent) +
24pt</xsl:attribute>
     <xsl:attribute name="space-before">1em</xsl:attribute>
     <xsl:attribute name="space-after">1em</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="pre">
     <xsl:attribute name="font-size">0.83em</xsl:attribute>
     <xsl:attribute name="font-family">monospace</xsl:attribute>
     <xsl:attribute name="white-space">pre</xsl:attribute>
     <xsl:attribute name="space-before">1em</xsl:attribute>
     <xsl:attribute name="space-after">1em</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="address">
     <xsl:attribute name="font-style">italic</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="hr">
     <xsl:attribute name="border"><xsl:call-template name="pxTopt"><xsl:with-param name="px" select="1"/></xsl:call-template> inset</xsl:attribute>
     <xsl:attribute name="space-before">0.67em</xsl:attribute>
     <xsl:attribute name="space-after">0.67em</xsl:attribute>
   </xsl:attribute-set>
   <!--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        List
   =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-->
   <xsl:attribute-set name="ul">
     <xsl:attribute name="space-before">1em</xsl:attribute>
     <xsl:attribute name="space-after">1em</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="ul-nested">
     <xsl:attribute name="space-before">0pt</xsl:attribute>
     <xsl:attribute name="space-after">0pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="ol">
     <xsl:attribute name="space-before">1em</xsl:attribute>
     <xsl:attribute name="space-after">1em</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="ol-nested">
     <xsl:attribute name="space-before">0pt</xsl:attribute>
     <xsl:attribute name="space-after">0pt</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="ul-li">
     <!-- for (unordered)fo:list-item -->
     <xsl:attribute name="relative-align">baseline</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="ol-li">
     <!-- for (ordered)fo:list-item -->
     <xsl:attribute name="relative-align">baseline</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="dl">
     <xsl:attribute name="space-before">1em</xsl:attribute>
     <xsl:attribute name="space-after">1em</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="dt">
     <xsl:attribute name="keep-with-next.within-column">always</xsl:attribute>
     <xsl:attribute name="keep-together.within-column">always</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="dd">
     <xsl:attribute name="start-indent">inherited-property-value(start-indent) +
24pt</xsl:attribute>
   </xsl:attribute-set>
   <!-- list-item-label format for each nesting level -->
   <xsl:param name="ul-label-1">&#x2022;</xsl:param>
   <xsl:attribute-set name="ul-label-1">
     <xsl:attribute name="font">1em serif</xsl:attribute>
   </xsl:attribute-set>
   <xsl:param name="ul-label-2">&#x25e6;</xsl:param>
   <xsl:attribute-set name="ul-label-2">
     <xsl:attribute name="font">0.67em monospace</xsl:attribute>
     <xsl:attribute name="baseline-shift">0.25em</xsl:attribute>
   </xsl:attribute-set>
   <xsl:param name="ul-label-3">&#x2012;</xsl:param>
   <xsl:attribute-set name="ul-label-3">
     <xsl:attribute name="font">bold 0.9em sans-serif</xsl:attribute>
     <xsl:attribute name="baseline-shift">0.05em</xsl:attribute>
   </xsl:attribute-set>
   <xsl:param name="ol-label-1">1.</xsl:param>
   <xsl:attribute-set name="ol-label-1"/>
   <xsl:param name="ol-label-2">a.</xsl:param>
   <xsl:attribute-set name="ol-label-2"/>
   <xsl:param name="ol-label-3">i.</xsl:param>
   <xsl:attribute-set name="ol-label-3"/>
   <!--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        Table
   =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-->
   <xsl:attribute-set name="inside-table">
     <!-- prevent unwanted inheritance -->
     <xsl:attribute name="start-indent">0pt</xsl:attribute>
     <xsl:attribute name="end-indent">0pt</xsl:attribute>
     <xsl:attribute name="text-indent">0pt</xsl:attribute>
     <xsl:attribute name="last-line-end-indent">0pt</xsl:attribute>
     <xsl:attribute name="text-align">start</xsl:attribute>
<!--      not Supported
     <xsl:attribute name="text-align-last">relative</xsl:attribute>-->
   </xsl:attribute-set>
   <xsl:attribute-set name="table-and-caption">
     <!-- horizontal alignment of table itself
     <xsl:attribute name="text-align">center</xsl:attribute>
     -->
     <!-- vertical alignment in table-cell -->
     <xsl:attribute name="display-align">center</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="table">
   <!--
     <xsl:attribute name="border-collapse">separate</xsl:attribute>
     <xsl:attribute name="border-spacing"><xsl:call-template name="pxTopt"><xsl:with-param name="px" select="2"/></xsl:call-template></xsl:attribute>
     <xsl:attribute name="border"><xsl:call-template name="pxTopt"><xsl:with-param name="px" select="1"/></xsl:call-template></xsl:attribute>
     <xsl:attribute name="border-style">outset</xsl:attribute>
     -->
   </xsl:attribute-set>
   <xsl:attribute-set name="table-caption" use-attribute-sets="inside-table">
     <xsl:attribute name="text-align">center</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="table-column">
   </xsl:attribute-set>
   <xsl:attribute-set name="thead" use-attribute-sets="inside-table">
   </xsl:attribute-set>
   <xsl:attribute-set name="tfoot" use-attribute-sets="inside-table">
   </xsl:attribute-set>
   <xsl:attribute-set name="tbody" use-attribute-sets="inside-table">
   </xsl:attribute-set>
   <xsl:attribute-set name="tr">
   </xsl:attribute-set>
   <xsl:attribute-set name="th">
     <xsl:attribute name="font-weight">bold</xsl:attribute>
     <xsl:attribute name="text-align">center</xsl:attribute>
     <xsl:attribute name="border"><xsl:call-template name="pxTopt"><xsl:with-param name="px" select="1"/></xsl:call-template></xsl:attribute>
     <!--
     <xsl:attribute name="border-style">inset</xsl:attribute>
     -->
     <xsl:attribute name="padding"><xsl:call-template name="pxTopt"><xsl:with-param name="px" select="1"/></xsl:call-template></xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="td">
     <xsl:attribute name="border"><xsl:call-template name="pxTopt"><xsl:with-param name="px" select="1"/></xsl:call-template></xsl:attribute>
     <!--
     <xsl:attribute name="border-style">inset</xsl:attribute>
     -->
     <xsl:attribute name="padding"><xsl:call-template name="pxTopt"><xsl:with-param name="px" select="1"/></xsl:call-template></xsl:attribute>
   </xsl:attribute-set>
   <!--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        Inline-level
   =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-->
   <xsl:attribute-set name="b">
     <xsl:attribute name="font-weight">bold</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="strong">
     <xsl:attribute name="font-weight">bold</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="strong-em">
     <xsl:attribute name="font-weight">bold</xsl:attribute>
     <xsl:attribute name="font-style">italic</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="i">
     <xsl:attribute name="font-style">italic</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="cite">
     <xsl:attribute name="font-style">italic</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="em">
     <xsl:attribute name="font-style">italic</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="var">
     <xsl:attribute name="font-style">italic</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="dfn">
     <xsl:attribute name="font-style">italic</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="tt">
     <xsl:attribute name="font-family">monospace</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="code">
     <xsl:attribute name="font-family">monospace</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="kbd">
     <xsl:attribute name="font-family">monospace</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="samp">
     <xsl:attribute name="font-family">monospace</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="big">
     <xsl:attribute name="font-size">larger</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="small">
     <xsl:attribute name="font-size">smaller</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="sub">
     <xsl:attribute name="baseline-shift">sub</xsl:attribute>
     <xsl:attribute name="font-size">smaller</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="sup">
     <xsl:attribute name="baseline-shift">super</xsl:attribute>
     <xsl:attribute name="font-size">smaller</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="s">
     <xsl:attribute name="text-decoration">line-through</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="strike">
     <xsl:attribute name="text-decoration">line-through</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="del">
     <xsl:attribute name="text-decoration">line-through</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="u">
     <xsl:attribute name="text-decoration">underline</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="ins">
     <xsl:attribute name="text-decoration">underline</xsl:attribute>
   </xsl:attribute-set>
   <xsl:attribute-set name="abbr">
     <!-- e.g.,
     <xsl:attribute name="font-variant">small-caps</xsl:attribute>
     <xsl:attribute name="letter-spacing">0.1em</xsl:attribute>
     -->
   </xsl:attribute-set>
   <xsl:attribute-set name="acronym">
     <!-- e.g.,
     <xsl:attribute name="font-variant">small-caps</xsl:attribute>
     <xsl:attribute name="letter-spacing">0.1em</xsl:attribute>
     -->
   </xsl:attribute-set>
   <xsl:attribute-set name="q"/>
   <xsl:attribute-set name="q-nested"/>
   <!--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        Image
   =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-->
   <xsl:attribute-set name="img">
   </xsl:attribute-set>
   <xsl:attribute-set name="img-link">
     <xsl:attribute name="border"><xsl:call-template name="pxTopt"><xsl:with-param name="px" select="2"/></xsl:call-template> solid</xsl:attribute>
   </xsl:attribute-set>
   <!--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        Link
   =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-->
   <xsl:attribute-set name="a-link">
     <xsl:attribute name="text-decoration">underline</xsl:attribute>
     <xsl:attribute name="color">blue</xsl:attribute>
   </xsl:attribute-set>
 
<!--======================================================================
       Templates
 
=======================================================================-->
   <!--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        Root
   =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-->
   <xsl:template match="/html | /html:html">
     <fo:root xsl:use-attribute-sets="root">
       <xsl:call-template name="process-common-attributes"/>
       <xsl:call-template name="make-layout-master-set"/>
		 <xsl:if test="$includeTocBookmarks">
		 	 <xsl:call-template name="toc-bookmarks-root"/>
		 </xsl:if>
       <xsl:apply-templates/>
     </fo:root>
   </xsl:template>
	<!-- Catch invalidly nested html documents, and treat like a <div> -->
	<xsl:template match="html[parent::*] | html:html[parent::html:*]">
		<fo:block>
        <xsl:apply-templates select="body/node() | html:body/node()"/>
      </fo:block>
	</xsl:template>
   <xsl:template name="make-layout-master-set">
     <fo:layout-master-set>
       <fo:simple-page-master master-name="all-pages" xsl:use-attribute-sets="page">
         <fo:region-body column-count="{$column-count}" column-gap="{$column-gap}" margin-bottom="{$page-margin-bottom}" margin-left="{$page-margin-left}" margin-right="{$page-margin-right}" margin-top="{$page-margin-top}"/>
         <xsl:choose>
           <xsl:when test="$writing-mode = 'tb-rl'">
             <fo:region-before extent="{$page-margin-right}" precedence="true"/>
             <fo:region-after extent="{$page-margin-left}" precedence="true"/>
             <fo:region-start display-align="before" extent="{$page-margin-top}" region-name="page-header" writing-mode="lr-tb"/>
             <fo:region-end display-align="after" extent="{$page-margin-bottom}" region-name="page-footer" writing-mode="lr-tb"/>
           </xsl:when>
           <xsl:when test="$writing-mode = 'rl-tb'">
             <fo:region-before display-align="before" extent="{$page-margin-top}" region-name="page-header"/>
             <fo:region-after display-align="after" extent="{$page-margin-bottom}" region-name="page-footer"/>
             <fo:region-start extent="{$page-margin-right}"/>
             <fo:region-end extent="{$page-margin-left}"/>
           </xsl:when>
           <xsl:otherwise><!-- $writing-mode = 'lr-tb' -->
             <fo:region-before display-align="before" extent="{$page-margin-top}" region-name="page-header"/>
             <fo:region-after display-align="after" extent="{$page-margin-bottom}" region-name="page-footer"/>
             <fo:region-start extent="{$page-margin-left}"/>
             <fo:region-end extent="{$page-margin-bottom}"/>
           </xsl:otherwise>
         </xsl:choose>
       </fo:simple-page-master>
     </fo:layout-master-set>
   </xsl:template>
   <xsl:template match="head | script | html:head | html:script"/>
	<!-- Table of Contents -->
	<xsl:template name="toc-bookmarks-root">
		<fo:bookmark-tree>
			<xsl:apply-templates mode="toc-bookmarks" select=".//*[local-name() = concat('h',substring($tocHeadingLevels,1,1))] | .//html:*[local-name() = concat('h',substring($tocHeadingLevels,1,1))]"/>
		</fo:bookmark-tree>
	</xsl:template>
	<xsl:template match="h1 | html:h1 | h2 | html:h2 | h3 | html:h3 | h4 | html:h4 | h5 | html:h5 | h6" mode="toc">
		<xsl:variable name="offset" select="string-length(substring-before($tocHeadingLevels,substring(local-name(),2,1))) + 1"/>
		<fo:block start-indent="{$offset}em" text-align-last="justify" text-indent="-{$offset}em">
			<fo:inline padding-start="{$offset}em">
				<fo:basic-link internal-destination="{generate-id()}">
				<xsl:value-of select="normalize-space(.)"/>
				<fo:leader leader-pattern="dots"/>
				<fo:page-number-citation ref-id="{generate-id()}"/>
				</fo:basic-link>
			</fo:inline>
		</fo:block>
	</xsl:template>
	<xsl:template match="h1 | html:h1 | h2 | html:h2 | h3 | html:h3 | h4 | html:h4 | h5 | html:h5 | h6" mode="toc-bookmarks">
		<xsl:variable name="offset" select="string-length(substring-before($tocHeadingLevels,substring(local-name(),2,1))) + 1"/>
		<xsl:variable name="currentLocalName" select="local-name()"/>
		<fo:bookmark internal-destination="{generate-id()}">
			<fo:bookmark-title><xsl:value-of select="normalize-space(.)"/></fo:bookmark-title>
			<xsl:apply-templates mode="toc-bookmarks" select="following::*[local-name() = concat('h',substring($tocHeadingLevels,$offset + 1,1)) and generate-id(preceding::*[local-name() = $currentLocalName][1]) = generate-id(current())] | following::html:*[local-name() = concat('h',substring($tocHeadingLevels,$offset + 1,1)) and generate-id(preceding::html:*[local-name() = $currentLocalName][1]) = generate-id(current())]"/>
		</fo:bookmark>
	</xsl:template>
	<!-- /Table of Contents -->
   <xsl:template match="body | html:body">
     <fo:page-sequence master-reference="all-pages">
       <fo:static-content flow-name="page-header">
         <fo:block space-before="{$page-header-margin}" space-before.conditionality="retain" xsl:use-attribute-sets="page-header">
           <xsl:if test="$title-print-in-header = 'true'">
             <xsl:value-of select="/html/head/title | /html:html/html:head/html:title"/>
           </xsl:if>
         </fo:block>
       </fo:static-content>
       <fo:static-content flow-name="page-footer">
         <fo:block space-after="{$page-footer-margin}" space-after.conditionality="retain" xsl:use-attribute-sets="page-footer">
           <xsl:if test="$page-number-print-in-footer = 'true'">
             <fo:page-number/>
           </xsl:if>
         </fo:block>
       </fo:static-content>
       <fo:flow flow-name="xsl-region-body">
			<xsl:if test="$includeTocPrinted and (.//*[translate(local-name(),$tocHeadingLevels,'#######') = 'h#'] | .//html:*[translate(local-name(),$tocHeadingLevels,'#######') = 'h#'])">
				<fo:block font-weight="bold" space-after="14pt" space-before="14pt" text-align="center">
					<xsl:choose>
						<xsl:when test="string-length($tocTitle) > 0">
								<fo:inline><xsl:value-of select="$tocTitle"/></fo:inline>
						</xsl:when>
						<xsl:otherwise>
							<fo:inline>Table of Contents</fo:inline>
						</xsl:otherwise>
					</xsl:choose>
				</fo:block>
	       	<xsl:apply-templates mode="toc" select=".//*[translate(local-name(),$tocHeadingLevels,'#######') = 'h#'] | .//html:*[translate(local-name(),$tocHeadingLevels,'#######') = 'h#']"/>
			</xsl:if>
         <fo:block xsl:use-attribute-sets="body">
           <xsl:call-template name="process-common-attributes"/>
           <xsl:apply-templates/>
         </fo:block>
       </fo:flow>
     </fo:page-sequence>
   </xsl:template>
   <!--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
    process common attributes and children
   =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-->
   <xsl:template name="process-common-attributes-and-children">
     <xsl:call-template name="process-common-attributes"/>
     <xsl:apply-templates/>
   </xsl:template>
   <xsl:template name="process-common-attributes">
<!--
     <xsl:attribute name="role">
       <xsl:value-of select="local-name()"></xsl:value-of>
     </xsl:attribute>
     <xsl:choose>
       <xsl:when test="@xml:lang">
         <xsl:attribute name="xml:lang">
           <xsl:value-of select="@xml:lang"></xsl:value-of>
         </xsl:attribute>
       </xsl:when>
       <xsl:when test="@lang">
         <xsl:attribute name="xml:lang">
           <xsl:value-of select="@lang"></xsl:value-of>
         </xsl:attribute>
       </xsl:when>
     </xsl:choose>
  -->
     <xsl:choose>
       <xsl:when test="@id">
         <xsl:attribute name="id">
           <xsl:value-of select="@id"/>
         </xsl:attribute>
       </xsl:when>
       <xsl:when test="self::a/@name | self::html:a/@name">
         <xsl:attribute name="id">
           <xsl:value-of select="@name"/>
         </xsl:attribute>
       </xsl:when>
     </xsl:choose>
     <xsl:if test="@align">
       <xsl:choose>
         <xsl:when test="self::caption | self::html:caption">
         </xsl:when>
         <xsl:when test="self::img | self::html:img or self::object | self::html:object">
           <xsl:if test="@align = 'bottom' or @align = 'middle' or @align = 'top'">
             <xsl:attribute name="vertical-align">
               <xsl:value-of select="@align"/>
             </xsl:attribute>
           </xsl:if>
         </xsl:when>
         <xsl:otherwise>
           <xsl:call-template name="process-cell-align">
             <xsl:with-param name="align" select="@align"/>
           </xsl:call-template>
         </xsl:otherwise>
       </xsl:choose>
     </xsl:if>
     <xsl:if test="@valign">
       <xsl:call-template name="process-cell-valign">
         <xsl:with-param name="valign" select="@valign"/>
       </xsl:call-template>
     </xsl:if>
     <xsl:if test="@style">
       <xsl:call-template name="process-style">
         <xsl:with-param name="style" select="@style"/>
       </xsl:call-template>
     </xsl:if>
   </xsl:template>
   <xsl:template name="process-style">
     <xsl:param name="style"/>
     <!-- e.g., style="text-align: center; color: red"
          converted to text-align="center" color="red" -->
     <xsl:variable name="name" select="normalize-space(substring-before($style, ':'))"/>
     <xsl:if test="$name">
       <xsl:variable name="value-and-rest" select="normalize-space(substring-after($style, ':'))"/>
       <xsl:variable name="value">
         <xsl:choose>
           <xsl:when test="contains($value-and-rest, ';')">
             <xsl:value-of select="normalize-space(substring-before(                                 $value-and-rest, ';'))"/>
           </xsl:when>
           <xsl:otherwise>
             <xsl:value-of select="$value-and-rest"/>
           </xsl:otherwise>
         </xsl:choose>
       </xsl:variable>
       <xsl:choose>
         <xsl:when test="$name = 'width' and (self::col or self::colgroup)">
           <xsl:attribute name="column-width">
             <xsl:value-of select="$value"/>
           </xsl:attribute>
         </xsl:when>
         <xsl:when test="$name = 'vertical-align' and (                   self::table or self::caption or             self::thead or self::tfoot or     self::tbody or self::colgroup or self::col or self::tr or                                  self::th or self::td)">
           <xsl:choose>
             <xsl:when test="$value = 'top'">
               <xsl:attribute name="display-align">before</xsl:attribute>
             </xsl:when>
             <xsl:when test="$value = 'bottom'">
               <xsl:attribute name="display-align">after</xsl:attribute>
             </xsl:when>
             <xsl:when test="$value = 'middle'">
               <xsl:attribute name="display-align">center</xsl:attribute>
             </xsl:when>
             <xsl:otherwise>
               <xsl:attribute name="display-align">auto</xsl:attribute>
               <xsl:attribute name="relative-align">baseline</xsl:attribute>
             </xsl:otherwise>
           </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
         <!--
           <xsl:attribute name="{$name}">
             <xsl:value-of select="$value"></xsl:value-of>
           </xsl:attribute>
        -->
         </xsl:otherwise>
       </xsl:choose>
     </xsl:if>
     <xsl:variable name="rest" select="normalize-space(substring-after($style, ';'))"/>
     <xsl:if test="$rest">
       <xsl:call-template name="process-style">
         <xsl:with-param name="style" select="$rest"/>
       </xsl:call-template>
     </xsl:if>
   </xsl:template>
   <!--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        Block-level
   =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-->
   <xsl:template match="h1 | html:h1">
     <fo:block id="{generate-id()}" xsl:use-attribute-sets="h1">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:block>
   </xsl:template>
   <xsl:template match="h2 | html:h2">
     <fo:block id="{generate-id()}" xsl:use-attribute-sets="h2">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:block>
   </xsl:template>
   <xsl:template match="h3 | html:h3">
     <fo:block id="{generate-id()}" xsl:use-attribute-sets="h3">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:block>
   </xsl:template>
   <xsl:template match="h4 | html:h4">
     <fo:block id="{generate-id()}" xsl:use-attribute-sets="h4">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:block>
   </xsl:template>
   <xsl:template match="h5 | html:h5">
     <fo:block id="{generate-id()}" xsl:use-attribute-sets="h5">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:block>
   </xsl:template>
   <xsl:template match="h6 | html:h6">
     <fo:block id="{generate-id()}" xsl:use-attribute-sets="h6">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:block>
   </xsl:template>
   <xsl:template match="p | html:p">
     <fo:block xsl:use-attribute-sets="p">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:block>
   </xsl:template>
   <!-- initial paragraph, preceded by h1..6 or div -->
   <xsl:template match="p[preceding-sibling::*[1][self::h1 or self::h2 or self::h3 or self::h4 or self::h5 or self::h6 or self::div]] | html:p[preceding-sibling::html:*[1][self::html:h1 or self::html:h2 or self::html:h3 or self::html:h4 or self::html:h5 or self::html:h6 or self::html:div]]">
     <fo:block xsl:use-attribute-sets="p-initial">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:block>
   </xsl:template>
   <!-- initial paragraph, first child of div, body or td -->
   <xsl:template match="p[not(preceding-sibling::*) and (parent::div or parent::body or parent::td)] | html:p[not(preceding-sibling::html:*) and (parent::html:div or parent::html:body or parent::html:td)]">
     <fo:block xsl:use-attribute-sets="p-initial-first">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:block>
   </xsl:template>
   <xsl:template match="blockquote | html:blockquote">
     <fo:block xsl:use-attribute-sets="blockquote">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:block>
   </xsl:template>
   <xsl:template match="pre | html:pre">
     <fo:block xsl:use-attribute-sets="pre">
       <xsl:call-template name="process-pre"/>
     </fo:block>
   </xsl:template>
   <xsl:template name="process-pre">
     <xsl:call-template name="process-common-attributes"/>
     <!-- remove leading CR/LF/CRLF char -->
     <xsl:variable name="crlf"><xsl:text>&#xd;
</xsl:text></xsl:variable>
     <xsl:variable name="lf"><xsl:text>
</xsl:text></xsl:variable>
     <xsl:variable name="cr"><xsl:text>&#xd;</xsl:text></xsl:variable>
     <xsl:for-each select="node()">
       <xsl:choose>
         <xsl:when test="position() = 1 and self::text()">
           <xsl:choose>
             <xsl:when test="starts-with(., $lf)">
               <xsl:value-of select="substring(., 2)"/>
             </xsl:when>
             <xsl:when test="starts-with(., $crlf)">
               <xsl:value-of select="substring(., 3)"/>
             </xsl:when>
             <xsl:when test="starts-with(., $cr)">
               <xsl:value-of select="substring(., 2)"/>
             </xsl:when>
             <xsl:otherwise>
               <xsl:apply-templates select="."/>
             </xsl:otherwise>
           </xsl:choose>
         </xsl:when>
         <xsl:otherwise>
           <xsl:apply-templates select="."/>
         </xsl:otherwise>
       </xsl:choose>
     </xsl:for-each>
   </xsl:template>
   <xsl:template match="address | html:address">
     <fo:block xsl:use-attribute-sets="address">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:block>
   </xsl:template>
   <xsl:template match="hr | html:hr">
     <fo:block xsl:use-attribute-sets="hr">
       <xsl:call-template name="process-common-attributes"/>
     </fo:block>
   </xsl:template>
   <xsl:template match="div | html:div">
     <!-- need fo:block-container? or normal fo:block -->
     <xsl:variable name="need-block-container">
     false
     <!--
       <xsl:call-template name="need-block-container"></xsl:call-template>
     -->
     </xsl:variable>
     <xsl:choose>
       <xsl:when test="$need-block-container = 'true'">
         <fo:block-container>
           <xsl:if test="@dir">
             <xsl:attribute name="writing-mode">
               <xsl:choose>
                 <xsl:when test="@dir = 'rtl'">rl-tb</xsl:when>
                 <xsl:otherwise>lr-tb</xsl:otherwise>
               </xsl:choose>
             </xsl:attribute>
           </xsl:if>
           <xsl:call-template name="process-common-attributes"/>
           <fo:block end-indent="0pt" start-indent="0pt">
             <xsl:apply-templates/>
           </fo:block>
         </fo:block-container>
       </xsl:when>
       <xsl:otherwise>
         <!-- normal block -->
         <fo:block>
           <xsl:call-template name="process-common-attributes"/>
           <xsl:apply-templates/>
         </fo:block>
       </xsl:otherwise>
     </xsl:choose>
   </xsl:template>
   <xsl:template name="need-block-container">
     <xsl:choose>
       <xsl:when test="@dir">true</xsl:when>
       <xsl:when test="@style">
         <xsl:variable name="s" select="concat(';', translate(normalize-space(@style),' ',''))"/>
         <xsl:choose>
           <xsl:when test="contains($s, ';width:') or          contains($s, ';height:') or contains($s, ';position:absolute') or contains($s, ';position:fixed') or contains($s, ';writing-mode:')">true</xsl:when>
           <xsl:otherwise>false</xsl:otherwise>
         </xsl:choose>
       </xsl:when>
       <xsl:otherwise>false</xsl:otherwise>
     </xsl:choose>
   </xsl:template>
   <xsl:template match="center | html:center">
     <fo:block text-align="center">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:block>
   </xsl:template>
   <xsl:template match="fieldset | html:fieldset | form | html:form | dir | html:dir | menu | html:menu">
     <fo:block space-after="1em" space-before="1em">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:block>
   </xsl:template>
   <!--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        List
   =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-->
   <xsl:template match="ul | html:ul">
     <fo:list-block xsl:use-attribute-sets="ul">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:list-block>
   </xsl:template>
   <xsl:template match="li//ul | html:li//html:ul">
     <fo:list-block xsl:use-attribute-sets="ul-nested">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:list-block>
   </xsl:template>
   <xsl:template match="ol | html:ol">
     <fo:list-block xsl:use-attribute-sets="ol">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:list-block>
   </xsl:template>
   <xsl:template match="li//ol | html:li//html:ol">
     <fo:list-block xsl:use-attribute-sets="ol-nested">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:list-block>
   </xsl:template>
   <xsl:template match="ul/li | html:ul/html:li">
     <fo:list-item xsl:use-attribute-sets="ul-li">
       <xsl:call-template name="process-ul-li"/>
     </fo:list-item>
   </xsl:template>
   <xsl:template name="process-ul-li">
     <xsl:call-template name="process-common-attributes"/>
     <fo:list-item-label end-indent="label-end()" text-align="end" wrap-option="no-wrap">
       <fo:block>
         <xsl:variable name="depth" select="count(ancestor::ul | ancestor::html:ul)"/>
         <xsl:choose>
           <xsl:when test="$depth = 1">
             <fo:inline xsl:use-attribute-sets="ul-label-1">
               <xsl:value-of select="$ul-label-1"/>
             </fo:inline>
           </xsl:when>
           <xsl:when test="$depth = 2">
             <fo:inline xsl:use-attribute-sets="ul-label-2">
               <xsl:value-of select="$ul-label-2"/>
             </fo:inline>
           </xsl:when>
           <xsl:otherwise>
             <fo:inline xsl:use-attribute-sets="ul-label-3">
               <xsl:value-of select="$ul-label-3"/>
             </fo:inline>
           </xsl:otherwise>
         </xsl:choose>
       </fo:block>
     </fo:list-item-label>
     <fo:list-item-body start-indent="body-start()">
       <fo:block>
         <xsl:apply-templates/>
       </fo:block>
     </fo:list-item-body>
   </xsl:template>
   <xsl:template match="ol/li | html:ol/html:li">
     <fo:list-item xsl:use-attribute-sets="ol-li">
       <xsl:call-template name="process-ol-li"/>
     </fo:list-item>
   </xsl:template>
   <xsl:template name="process-ol-li">
     <xsl:call-template name="process-common-attributes"/>
     <fo:list-item-label end-indent="label-end()" text-align="end" wrap-option="no-wrap">
       <fo:block>
         <xsl:variable name="depth" select="count(ancestor::ol | ancestor::html:ol)"/>
         <xsl:choose>
           <xsl:when test="$depth = 1">
             <fo:inline xsl:use-attribute-sets="ol-label-1">
               <xsl:number format="{$ol-label-1}"/>
             </fo:inline>
           </xsl:when>
           <xsl:when test="$depth = 2">
             <fo:inline xsl:use-attribute-sets="ol-label-2">
               <xsl:number format="{$ol-label-2}"/>
             </fo:inline>
           </xsl:when>
           <xsl:otherwise>
             <fo:inline xsl:use-attribute-sets="ol-label-3">
               <xsl:number format="{$ol-label-3}"/>
             </fo:inline>
           </xsl:otherwise>
         </xsl:choose>
       </fo:block>
     </fo:list-item-label>
     <fo:list-item-body start-indent="body-start()">
       <fo:block>
         <xsl:apply-templates/>
       </fo:block>
     </fo:list-item-body>
   </xsl:template>
   <xsl:template match="dl | html:dl">
     <fo:block xsl:use-attribute-sets="dl">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:block>
   </xsl:template>
   <xsl:template match="dt | html:dt">
     <fo:block xsl:use-attribute-sets="dt">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:block>
   </xsl:template>
   <xsl:template match="dd | html:dd">
     <fo:block xsl:use-attribute-sets="dd">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:block>
   </xsl:template>
   <!--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        Table
   =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-->
   <xsl:template match="table | html:table">
        <fo:table xsl:use-attribute-sets="table">
           <xsl:call-template name="process-table"/>
       </fo:table>
<!--
     <fo:table-and-caption xsl:use-attribute-sets="table-and-caption">
       <xsl:call-template name="make-table-caption"></xsl:call-template>
       <fo:table xsl:use-attribute-sets="table">
         <xsl:call-template name="process-table"></xsl:call-template>
       </fo:table>
     </fo:table-and-caption>
-->
   </xsl:template>
   <xsl:template name="make-table-caption">
     <xsl:if test="caption/@align or html:caption/@align">
       <xsl:attribute name="caption-side">
         <xsl:value-of select="caption/@align | html:caption/@align"/>
       </xsl:attribute>
     </xsl:if>
     <xsl:apply-templates select="caption | html:caption"/>
   </xsl:template>
   <xsl:template name="process-table">
     <xsl:if test="@width">
       <xsl:attribute name="inline-progression-dimension">
         <xsl:choose>
           <xsl:when test="contains(@width, '%')">
             <xsl:value-of select="@width"/>
           </xsl:when>
           <xsl:otherwise>
             <xsl:call-template name="pxTopt"><xsl:with-param name="px" select="@width"/></xsl:call-template></xsl:otherwise>
         </xsl:choose>
       </xsl:attribute>
     </xsl:if>
   <xsl:if test="not(@width)">
      <xsl:attribute name="inline-progression-dimension">6in</xsl:attribute>
   </xsl:if>
     <xsl:if test="@border or @frame">
       <xsl:choose>
         <xsl:when test="@border > 0">
           <xsl:attribute name="border">
             <xsl:call-template name="pxTopt"><xsl:with-param name="px" select="@border"/></xsl:call-template></xsl:attribute>
         </xsl:when>
       </xsl:choose>
       <xsl:choose>
         <xsl:when test="@border = '0' or @frame = 'void'">
           <xsl:attribute name="border-style">hidden</xsl:attribute>
         </xsl:when>
         <xsl:when test="@frame = 'above'">
           <xsl:attribute name="border-style">outset hidden hidden
hidden</xsl:attribute>
         </xsl:when>
         <xsl:when test="@frame = 'below'">
           <xsl:attribute name="border-style">hidden hidden outset
hidden</xsl:attribute>
         </xsl:when>
         <xsl:when test="@frame = 'hsides'">
           <xsl:attribute name="border-style">outset hidden</xsl:attribute>
         </xsl:when>
         <xsl:when test="@frame = 'vsides'">
           <xsl:attribute name="border-style">hidden outset</xsl:attribute>
         </xsl:when>
         <xsl:when test="@frame = 'lhs'">
           <xsl:attribute name="border-style">hidden hidden hidden
outset</xsl:attribute>
         </xsl:when>
         <xsl:when test="@frame = 'rhs'">
           <xsl:attribute name="border-style">hidden outset hidden
hidden</xsl:attribute>
         </xsl:when>
         <xsl:otherwise>
           <xsl:attribute name="border-style">solid</xsl:attribute><!--Bob changed this from outset-->
         </xsl:otherwise>
       </xsl:choose>
     </xsl:if>
     <xsl:if test="@cellspacing">
       <!-- removed by Bob
       <xsl:attribute name="border-spacing">
         <xsl:call-template name="pxTopt"><xsl:with-param name="px" select="@cellspacing"/></xsl:call-template></xsl:attribute>
       <xsl:attribute name="border-collapse">separate</xsl:attribute>
       -->
     </xsl:if>
     <xsl:if test="@rules and (@rules = 'groups' or @rules = 'rows' or @rules = 'cols' or @rules = 'all' and (not(@border or @frame) or @border = '0' or @frame and not(@frame = 'box' or @frame = 'border')))">
       <xsl:attribute name="border-collapse">collapse</xsl:attribute>
       <xsl:if test="not(@border or @frame)">
         <xsl:attribute name="border-style">hidden</xsl:attribute>
       </xsl:if>
     </xsl:if>
     <xsl:choose>
      <xsl:when test="col | html:col | colgroup | html:colgroup">
         <xsl:apply-templates select="col | html:col | colgroup | html:colgroup"/>
      </xsl:when>
      <xsl:otherwise>
         <xsl:call-template name="create-columns"/>
      </xsl:otherwise>
     </xsl:choose>
     <xsl:call-template name="process-common-attributes"/>
     <xsl:apply-templates select="thead | html:thead"/>
     <xsl:apply-templates select="tfoot | html:tfoot"/>
     <xsl:choose>
       <xsl:when test="tbody or html:tbody">
         <xsl:apply-templates select="tbody | html:tbody"/>
       </xsl:when>
       <xsl:otherwise>
         <fo:table-body xsl:use-attribute-sets="tbody">
           <xsl:apply-templates select="tr | html:tr"/>
         </fo:table-body>
       </xsl:otherwise>
     </xsl:choose>
   </xsl:template>
   <xsl:template name="create-columns">
     <xsl:for-each select="tbody/tr | html:tbody/html:tr | tr | html:tr">
       <xsl:sort data-type="number" order="descending" select="count(td | html:td)"/>
         <xsl:if test="position()=1">
            <xsl:for-each select="td | html:td">
               <fo:table-column xsl:use-attribute-sets="table-column"/>
            </xsl:for-each>
        </xsl:if>
     </xsl:for-each>
   </xsl:template>
   <xsl:template match="caption | html:caption">
     <fo:table-caption xsl:use-attribute-sets="table-caption">
       <xsl:call-template name="process-common-attributes"/>
       <fo:block>
         <xsl:apply-templates/>
       </fo:block>
     </fo:table-caption>
   </xsl:template>
   <xsl:template match="thead | html:thead">
     <fo:table-header xsl:use-attribute-sets="thead">
       <xsl:call-template name="process-table-rowgroup"/>
     </fo:table-header>
   </xsl:template>
   <xsl:template match="tfoot | html:tfoot">
     <fo:table-footer xsl:use-attribute-sets="tfoot">
       <xsl:call-template name="process-table-rowgroup"/>
     </fo:table-footer>
   </xsl:template>
   <xsl:template match="tbody | html:tbody">
     <fo:table-body xsl:use-attribute-sets="tbody">
       <xsl:call-template name="process-table-rowgroup"/>
     </fo:table-body>
   </xsl:template>
   <xsl:template name="process-table-rowgroup">
     <xsl:if test="ancestor::table[1]/@rules = 'groups' or ancestor::html:table[1]/@rules = 'groups'">
       <xsl:attribute name="border"><xsl:call-template name="pxTopt"><xsl:with-param name="px" select="1"/></xsl:call-template> solid</xsl:attribute>
     </xsl:if>
     <xsl:call-template name="process-common-attributes-and-children"/>
   </xsl:template>
   <xsl:template match="colgroup | html:colgroup">
     <fo:table-column xsl:use-attribute-sets="table-column">
       <xsl:call-template name="process-table-column"/>
     </fo:table-column>
   </xsl:template>
   <xsl:template match="colgroup[col] | html:colgroup[html:col]">
     <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="col | html:col">
     <fo:table-column xsl:use-attribute-sets="table-column">
       <xsl:call-template name="process-table-column"/>
     </fo:table-column>
   </xsl:template>
   <xsl:template name="process-table-column">
     <xsl:if test="parent::colgroup | parent::html:colgroup">
       <xsl:call-template name="process-col-width">
         <xsl:with-param name="width" select="../@width"/>
       </xsl:call-template>
       <xsl:call-template name="process-cell-align">
         <xsl:with-param name="align" select="../@align"/>
       </xsl:call-template>
       <xsl:call-template name="process-cell-valign">
         <xsl:with-param name="valign" select="../@valign"/>
       </xsl:call-template>
     </xsl:if>
     <xsl:if test="@span">
       <xsl:attribute name="number-columns-repeated">
         <xsl:value-of select="@span"/>
       </xsl:attribute>
     </xsl:if>
     <xsl:call-template name="process-col-width">
       <xsl:with-param name="width" select="@width"/>
       <!-- it may override parent colgroup's width -->
     </xsl:call-template>
     <xsl:if test="ancestor::table[1]/@rules = 'cols' or ancestor::html:table[1]/@rules = 'cols'">
       <xsl:attribute name="border"><xsl:call-template name="pxTopt"><xsl:with-param name="px" select="1"/></xsl:call-template> solid</xsl:attribute>
     </xsl:if>
     <xsl:call-template name="process-common-attributes"/>
     <!-- this processes also align and valign -->
   </xsl:template>
   <xsl:template match="tr | html:tr">
     <fo:table-row xsl:use-attribute-sets="tr">
       <xsl:call-template name="process-table-row"/>
     </fo:table-row>
   </xsl:template>
   <xsl:template match="tr[parent::table and th and not(td)] | html:tr[parent::html:table and html:th and not(html:td)]">
     <fo:table-row keep-with-next="always" xsl:use-attribute-sets="tr">
       <xsl:call-template name="process-table-row"/>
     </fo:table-row>
   </xsl:template>
   <xsl:template name="process-table-row">
     <xsl:if test="ancestor::table[1]/@rules = 'rows' or ancestor::html:table[1]/@rules = 'rows'">
       <xsl:attribute name="border"><xsl:call-template name="pxTopt"><xsl:with-param name="px" select="1"/></xsl:call-template> solid</xsl:attribute>
     </xsl:if>
     <xsl:call-template name="process-common-attributes-and-children"/>
   </xsl:template>
   <xsl:template match="th | html:th">
     <fo:table-cell xsl:use-attribute-sets="th">
       <xsl:call-template name="process-table-cell"/>
     </fo:table-cell>
   </xsl:template>
   <xsl:template match="td | html:td">
     <fo:table-cell xsl:use-attribute-sets="td">
       <xsl:call-template name="process-table-cell"/>
     </fo:table-cell>
   </xsl:template>
   <xsl:template name="process-table-cell">
     <xsl:if test="@colspan">
       <xsl:attribute name="number-columns-spanned">
         <xsl:value-of select="@colspan"/>
       </xsl:attribute>
     </xsl:if>
     <xsl:if test="@rowspan">
       <xsl:attribute name="number-rows-spanned">
         <xsl:value-of select="@rowspan"/>
       </xsl:attribute>
     </xsl:if>
     <xsl:call-template name="process-col-width">
       <xsl:with-param name="width" select="@width"/>
       <!-- it may override related colgroup's or col's width -->
     </xsl:call-template>
     <xsl:for-each select="ancestor::table[1] | ancestor::html:table[1]">
       <xsl:if test="(@border or @rules) and (@rules = 'all' or not(@rules) and not(@border = '0'))">
         <xsl:attribute name="border-style">solid</xsl:attribute><!--Bob changed this from inset-->
       </xsl:if>
       <xsl:if test="@cellpadding">
         <xsl:attribute name="padding">
           <xsl:choose>
             <xsl:when test="contains(@cellpadding, '%')">
               <xsl:value-of select="@cellpadding"/>
             </xsl:when>
             <xsl:otherwise>
               <xsl:call-template name="pxTopt"><xsl:with-param name="px" select="@cellpadding"/></xsl:call-template></xsl:otherwise>
           </xsl:choose>
         </xsl:attribute>
       </xsl:if>
     </xsl:for-each>
     <xsl:if test="(not(@align or ../@align or ../parent::*[self::thead or self::tfoot or self::tbody]/@align) and ancestor::table[1]/*[self::col or self::colgroup]/descendant-or-self::*/@align) or (not(@align or ../@align or ../parent::html:*[self::html:thead or self::html:tfoot or self::html:tbody]/@align) and ancestor::html:table[1]/html:*[self::html:col or self::html:colgroup]/descendant-or-self::html:*/@align)">
       <xsl:attribute name="text-align">from-table-column()</xsl:attribute>
     </xsl:if>
     <xsl:if test="(not(@valign or ../@valign or ../parent::*[self::thead or self::tfoot or self::tbody]/@valign) and ancestor::table[1]/*[self::col or self::colgroup]/descendant-or-self::*/@valign) or (not(@valign or ../@valign or ../parent::html:*[self::html:thead or self::html:tfoot or self::html:tbody]/@valign) and ancestor::html:table[1]/html:*[self::html:col or self::html:colgroup]/descendant-or-self::html:*/@valign)">
       <xsl:attribute name="display-align">from-table-column()</xsl:attribute>
       <xsl:attribute name="relative-align">from-table-column()</xsl:attribute>
     </xsl:if>
     <xsl:call-template name="process-common-attributes"/>
     <fo:block>
       <xsl:apply-templates/>
     </fo:block>
   </xsl:template>
   <xsl:template name="process-col-width">
     <xsl:param name="width"/>
		<xsl:variable name="attributeName"><xsl:choose>
	  <xsl:when test="ancestor-or-self::colgroup | ancestor-or-self::html:colgroup | ancestor-or-self::col | ancestor-or-self::html:col">column-width</xsl:when>
		<xsl:otherwise>width</xsl:otherwise>
		</xsl:choose></xsl:variable>
     <xsl:if test="$width and $width != '0*'">
       <xsl:attribute name="{$attributeName}">
         <xsl:choose>
           <xsl:when test="contains($width, '*')">
             <xsl:text>proportional-column-width(</xsl:text>
             <xsl:value-of select="substring-before($width, '*')"/>
             <xsl:text>)</xsl:text>
           </xsl:when>
           <xsl:when test="contains($width, '%')">
             <xsl:value-of select="$width"/>
           </xsl:when>
           <xsl:otherwise>
             <xsl:call-template name="pxTopt"><xsl:with-param name="px" select="$width"/></xsl:call-template></xsl:otherwise>
         </xsl:choose>
       </xsl:attribute>
     </xsl:if>
   </xsl:template>
   <xsl:template name="process-cell-align">
     <xsl:param name="align"/>
<!--
     <xsl:if test="$align">
       <xsl:attribute name="text-align">
         <xsl:choose>
           <xsl:when test="$align = 'char'">
             <xsl:choose>
               <xsl:when test="$align/../@char">
                 <xsl:value-of select="$align/../@char"></xsl:value-of>
               </xsl:when>
               <xsl:otherwise>
                 <xsl:value-of select="'.'"></xsl:value-of>
               </xsl:otherwise>
             </xsl:choose>
           </xsl:when>
           <xsl:otherwise>
             <xsl:value-of select="$align"></xsl:value-of>
           </xsl:otherwise>
         </xsl:choose>
       </xsl:attribute>
     </xsl:if>
-->
   </xsl:template>
   <xsl:template name="process-cell-valign">
     <xsl:param name="valign"/>
     <xsl:if test="$valign">
       <xsl:attribute name="display-align">
         <xsl:choose>
           <xsl:when test="$valign = 'middle'">center</xsl:when>
           <xsl:when test="$valign = 'bottom'">after</xsl:when>
           <xsl:when test="$valign = 'baseline'">auto</xsl:when>
           <xsl:otherwise>before</xsl:otherwise>
         </xsl:choose>
       </xsl:attribute>
       <xsl:if test="$valign = 'baseline'">
         <xsl:attribute name="relative-align">baseline</xsl:attribute>
       </xsl:if>
     </xsl:if>
   </xsl:template>
   <!--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        Inline-level
   =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-->
   <xsl:template match="b | html:b">
     <fo:inline xsl:use-attribute-sets="b">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="strong | html:strong">
     <fo:inline xsl:use-attribute-sets="strong">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="strong//em | em//strong | html:strong//html:em | html:em//html:strong">
     <fo:inline xsl:use-attribute-sets="strong-em">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="i | html:i">
     <fo:inline xsl:use-attribute-sets="i">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="cite | html:cite">
     <fo:inline xsl:use-attribute-sets="cite">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="em | html:em">
     <fo:inline xsl:use-attribute-sets="em">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="var | html:var">
     <fo:inline xsl:use-attribute-sets="var">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="dfn | html:dfn">
     <fo:inline xsl:use-attribute-sets="dfn">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="tt | html:tt">
     <fo:inline xsl:use-attribute-sets="tt">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="code | html:code">
     <fo:inline xsl:use-attribute-sets="code">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="kbd | html:kbd">
     <fo:inline xsl:use-attribute-sets="kbd">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="samp | html:samp">
     <fo:inline xsl:use-attribute-sets="samp">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="big | html:big">
     <fo:inline xsl:use-attribute-sets="big">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="small | html:small">
     <fo:inline xsl:use-attribute-sets="small">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="sub | html:sub">
     <fo:inline xsl:use-attribute-sets="sub">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="sup | html:sup">
     <fo:inline xsl:use-attribute-sets="sup">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="s | html:s">
     <fo:inline xsl:use-attribute-sets="s">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="strike | html:strike">
     <fo:inline xsl:use-attribute-sets="strike">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="del | html:del">
     <fo:inline xsl:use-attribute-sets="del">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="u | html:u">
     <fo:inline xsl:use-attribute-sets="u">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="ins | html:ins">
     <fo:inline xsl:use-attribute-sets="ins">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="abbr | html:abbr">
     <fo:inline xsl:use-attribute-sets="abbr">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="acronym | html:acronym">
     <fo:inline xsl:use-attribute-sets="acronym">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="span | html:span">
     <fo:inline>
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="span[@dir] | html:span[@dir]">
     <fo:bidi-override direction="{@dir}" unicode-bidi="embed">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:bidi-override>
   </xsl:template>
   <xsl:template match="span[@style and contains(@style, 'writing-mode')] | html:span[@style and contains(@style, 'writing-mode')]">
     <fo:inline-container alignment-baseline="central" end-indent="0pt" last-line-end-indent="0pt" start-indent="0pt" text-align="center" text-align-last="center" text-indent="0pt">
       <xsl:call-template name="process-common-attributes"/>
       <fo:block line-height="1" wrap-option="no-wrap">
         <xsl:apply-templates/>
       </fo:block>
     </fo:inline-container>
   </xsl:template>
   <xsl:template match="bdo | html:bdo">
     <fo:bidi-override direction="{@dir}" unicode-bidi="bidi-override">
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:bidi-override>
   </xsl:template>
   <!-- Capture the br tag and output an empty block containing a non-breaking space (Unicode 0xa0) -->

   <xsl:template match="br | html:br">
      <fo:block line-height="0">&#160;</fo:block>
   </xsl:template>

   <xsl:template match="q | html:q">
     <fo:inline xsl:use-attribute-sets="q">
       <xsl:call-template name="process-common-attributes"/>
       <xsl:choose>
         <xsl:when test="lang('ja')">
           <xsl:text>?</xsl:text>
           <xsl:apply-templates/>
           <xsl:text>?</xsl:text>
         </xsl:when>
         <xsl:otherwise>
           <!-- lang('en') -->
           <xsl:text>?</xsl:text>
           <xsl:apply-templates/>
           <xsl:text>?</xsl:text>
           <!-- todo: other languages ...-->
         </xsl:otherwise>
       </xsl:choose>
     </fo:inline>
   </xsl:template>
   <xsl:template match="q//q | html:q//html:q">
     <fo:inline xsl:use-attribute-sets="q-nested">
       <xsl:call-template name="process-common-attributes"/>
       <xsl:choose>
         <xsl:when test="lang('ja')">
           <xsl:text>?</xsl:text>
           <xsl:apply-templates/>
           <xsl:text>?</xsl:text>
         </xsl:when>
         <xsl:otherwise>
           <!-- lang('en') -->
           <xsl:text>?</xsl:text>
           <xsl:apply-templates/>
           <xsl:text>?</xsl:text>
         </xsl:otherwise>
       </xsl:choose>
     </fo:inline>
   </xsl:template>
   <!--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        Image
   =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-->
   <xsl:template match="img | html:img">
     <fo:external-graphic xsl:use-attribute-sets="img">
       <xsl:call-template name="process-img"/>
     </fo:external-graphic>
   </xsl:template>
   <xsl:template match="img[ancestor::a/@href] | html:img[ancestor::html:a/@href]">
     <fo:external-graphic xsl:use-attribute-sets="img-link">
       <xsl:call-template name="process-img"/>
     </fo:external-graphic>
   </xsl:template>
   <xsl:template name="process-img">
     <xsl:attribute name="src">
 
<xsl:text>url('</xsl:text>[system-asset:embedded-image]<xsl:value-of select="@src"/>[/system-asset:embedded-image]<xsl:text>')</xsl:text>
     </xsl:attribute>
     <xsl:if test="@alt">
       <xsl:attribute name="role">
         <xsl:value-of select="@alt"/>
       </xsl:attribute>
     </xsl:if>
     <xsl:if test="@width">
       <xsl:choose>
         <xsl:when test="contains(@width, '%')">
           <xsl:attribute name="width">
             <xsl:value-of select="@width"/>
           </xsl:attribute>
           <xsl:attribute name="content-width">scale-to-fit</xsl:attribute>
         </xsl:when>
         <xsl:otherwise>
           <xsl:attribute name="content-width">
             <xsl:call-template name="pxTopt"><xsl:with-param name="px" select="@width"/></xsl:call-template></xsl:attribute>
         </xsl:otherwise>
       </xsl:choose>
     </xsl:if>
     <xsl:if test="@height">
       <xsl:choose>
         <xsl:when test="contains(@height, '%')">
           <xsl:attribute name="height">
             <xsl:value-of select="@height"/>
           </xsl:attribute>
           <xsl:attribute name="content-height">scale-to-fit</xsl:attribute>
         </xsl:when>
         <xsl:otherwise>
           <xsl:attribute name="content-height">
             <xsl:call-template name="pxTopt"><xsl:with-param name="px" select="@height"/></xsl:call-template></xsl:attribute>
         </xsl:otherwise>
       </xsl:choose>
     </xsl:if>
     <xsl:if test="@border">
       <xsl:attribute name="border">
         <xsl:call-template name="pxTopt"><xsl:with-param name="px" select="@border"/></xsl:call-template> solid</xsl:attribute>
     </xsl:if>
     <xsl:call-template name="process-common-attributes"/>
   </xsl:template>
   <xsl:template match="object | html:object">
     <xsl:apply-templates/>
   </xsl:template>
   <xsl:template match="param | html:param"/>
   <xsl:template match="map | html:map"/>
   <xsl:template match="area | html:area"/>
   <xsl:template match="label | html:label"/>
   <xsl:template match="input | html:input"/>
   <xsl:template match="select | html:select"/>
   <xsl:template match="optgroup | html:optgroup"/>
   <xsl:template match="option | html:option"/>
   <xsl:template match="textarea | html:textarea"/>
   <xsl:template match="legend | html:legend"/>
   <xsl:template match="button | html:button"/>
   <xsl:template match="style | html:style"/>
   <xsl:template match="iframe | html:iframe">
		<xsl:if test="@src">
			<xsl:variable name="newDoc" select="document(string(@src))"/>
			<xsl:if test="count($newDoc/descendant-or-self::node()) = 0">
				<fo:block xsl:use-attribute-sets="p">
					<fo:inline color="#ff0000">Unable to load contents of IFRAME at this location in the original document. See original HTML document and notify an administrator.</fo:inline>
			   </fo:block>
			</xsl:if>
			<xsl:apply-templates select="$newDoc"/>
		</xsl:if>
	</xsl:template>
   <!--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        Link
   =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-->
   <xsl:template match="a | html:a">
     <fo:inline>
       <xsl:call-template name="process-common-attributes-and-children"/>
     </fo:inline>
   </xsl:template>
   <xsl:template match="a[@href] | html:a[@href]">
     <fo:basic-link xsl:use-attribute-sets="a-link">
       <xsl:call-template name="process-a-link"/>
     </fo:basic-link>
   </xsl:template>
   <xsl:template name="process-a-link">
     <xsl:call-template name="process-common-attributes"/>
     <xsl:choose>
       <xsl:when test="starts-with(@href,'#')"><!-- Linking to the same page -->
         <xsl:attribute name="internal-destination">
           <xsl:value-of select="substring-after(@href,'#')"/>
         </xsl:attribute>
       </xsl:when>
       <xsl:when test="starts-with(@href, '/')"><!-- The link is internal to the CMS -->
	       <xsl:choose>
	         <xsl:when test="contains(@href, '#')"><!-- If it contains a #, we may need to rewrite the extension -->
	           <xsl:choose>
	             <xsl:when test="substring(substring-before(@href, '#'), string-length(substring-before(@href,'#')) - 3, 1) = '.' or substring(substring-before(@href, '#'), string-length(substring-before(@href,'#')) - 4, 1) = '.'">
	             <!-- when the portion before the # ends with a .??? or .???? then it is probably a file extension
	                  and we can use that for the link with just the beginning of the URL rewritten -->
	               <xsl:attribute name="external-destination"><xsl:value-of select="$serverURL" /><xsl:value-of select="substring-after(@href, '/')"/></xsl:attribute>
	             </xsl:when>
	             <xsl:otherwise>
	             <!-- If there isn't a file extension, then we default to html -->
	               <xsl:attribute name="external-destination">
	                 <xsl:value-of select="$serverURL" /><xsl:value-of select="substring-after(substring-before(@href, '#'), '/')"/>.html#<xsl:value-of select="substring-after(@href, '#')"/>
	               </xsl:attribute>
	       	     </xsl:otherwise>
	       	   </xsl:choose>
	       	 </xsl:when>
	       	 <xsl:otherwise><!-- Meaning - the href does not contain a # -->
	       	   <xsl:choose>
	       	     <xsl:when test="substring(@href, string-length(@href) - 3, 1) = '.' or substring(@href, string-length(@href) - 4, 1) = '.'"><!--Check to see if there is a file extension-->
	       	       <xsl:attribute name="external-destination"><xsl:value-of select="$serverURL" /><xsl:value-of select="substring-after(@href, '/')"/></xsl:attribute>
	       	     </xsl:when>
	       	     <xsl:otherwise>
	       	       <xsl:attribute name="external-destination"><xsl:value-of select="$serverURL" /><xsl:value-of select="substring-after(@href, '/')"/>.html</xsl:attribute>
	       	     </xsl:otherwise>
	       	   </xsl:choose>
	       	 </xsl:otherwise>
	       </xsl:choose>
        </xsl:when>
        <xsl:otherwise>
         <xsl:attribute name="external-destination">url('<xsl:value-of select="@href"/>')</xsl:attribute>
        </xsl:otherwise>
     </xsl:choose>
     <xsl:if test="@title">
       <xsl:attribute name="role">
         <xsl:value-of select="@title"/>
       </xsl:attribute>
     </xsl:if>
     <xsl:apply-templates/>
   </xsl:template>
   <!--=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-
        Ruby
   =-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-=-->
   <xsl:template match="ruby | html:ruby">
     <fo:inline-container alignment-baseline="central" block-progression-dimension="1em" end-indent="0pt" last-line-end-indent="0pt" start-indent="0pt" text-align="center" text-align-last="center" text-indent="0pt">
       <xsl:call-template name="process-common-attributes"/>
       <fo:block font-size="50%" line-height="1" role="rt" space-after="0.1em" space-before="-1.1em" space-before.conditionality="retain" wrap-option="no-wrap">
         <xsl:for-each select="rt | html:rt | rtc[1]/rt | html:rtc[1]/html:rt">
           <xsl:call-template name="process-common-attributes"/>
           <xsl:apply-templates/>
         </xsl:for-each>
       </fo:block>
       <fo:block line-height="1" role="rb" wrap-option="no-wrap">
         <xsl:for-each select="rb | rbc[1]/rb | html:rb | html:rbc[1]/html:rb">
           <xsl:call-template name="process-common-attributes"/>
           <xsl:apply-templates/>
         </xsl:for-each>
       </fo:block>
       <xsl:if test="rtc[2]/rt | html:rtc[2]/html:rt">
         <fo:block font-size="50%" line-height="1" role="rt" space-after="-1.1em" space-after.conditionality="retain" space-before="0.1em" wrap-option="no-wrap">
           <xsl:for-each select="rt | rtc[2]/rt | html:rt | html:rtc[2]/html:rt">
             <xsl:call-template name="process-common-attributes"/>
             <xsl:apply-templates/>
           </xsl:for-each>
         </fo:block>
       </xsl:if>
     </fo:inline-container>
   </xsl:template>
<xsl:template match="system-page-display-name | html:system-page-display-name | system-page-title | html:system-page-title | system-page-summary | html:system-page-summary">
<xsl:copy-of select="."/>
</xsl:template>

<!-- Convert pixel measurements to points based on pixelsPerInch param -->
<xsl:template name="pxTopt">
	<xsl:param name="px"/>
	<xsl:variable name="fopResolution" select="72"/>
	<!-- Assumes page size given in inches ['in' suffix] -->
	<xsl:variable name="pageWidthInPt" select="(number(substring-before($page-width,'in')) - (number(substring-before($page-margin-left,'in')) + number(substring-before($page-margin-right,'in')))) * $fopResolution" />
	<xsl:choose>
		<xsl:when test="$fitToPageWidth and (number($px) div number($pixelsPerInch) * $fopResolution) > $pageWidthInPt">
			<xsl:value-of select="concat(string($pageWidthInPt),'pt')"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:value-of select="concat(string(number($px) div number($pixelsPerInch) * $fopResolution),'pt')"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>
</xsl:stylesheet>
