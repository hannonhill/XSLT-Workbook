<?xml version="1.0" encoding="UTF-8" ?>
<!--
	Split Paragraphs into Columns
	Created by Ross Williams on 2009-09-25.
	Copyright (c) 2009 Hannon Hill Corp. All rights reserved.
-->

<xsl:stylesheet version="1.0"
                xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
					 xmlns:exsl="http://exslt.org/common"
					 exclude-result-prefixes="exsl">

	<xsl:output encoding="UTF-8" indent="yes" method="xml" />
	
	<xsl:variable name="numColumns">3</xsl:variable>

	<xsl:template match="/">
		<!--
			Make a choice about what kind of data to process.
			The defaults included below handle:
				1) A system-index-block as if it contains the XHTML of the current page.
					It then splits the current page's XHTML up into columns with an equal
					number of nodes.
				2) A system-data-structure is unhandled, but there is a placeholder here
					to allow you to customize which nodes should be selected (perhaps a
					particular WYSIWYG from within the structured data that you wish to
					split into columns?).
				3) Any other case is treated as if this XSLT is being applied directly to
					the WYSIWYG of a Page without a Data Definition. It looks at all the
					top-level nodes of the Page's XHTML content and splits into columns
					with equal numbers of nodes.
		-->
		<xsl:choose>
			<xsl:when test="system-index-block/calling-page/system-page/page-xhtml">
				<xsl:call-template name="toColumns">
					<xsl:with-param name="nodes" select="system-index-block/calling-page/system-page/page-xhtml/node()"/>
				</xsl:call-template>
			</xsl:when>
			<xsl:when test="system-data-structure">
				[system-view:internal]<p>You must modify the XSLT to support your Structured Data.</p>[/system-view:internal]
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="toColumns">
					<xsl:with-param name="nodes" select="node()" />
				</xsl:call-template>
			</xsl:otherwise>
		</xsl:choose>
	</xsl:template>
	
	<!--
		The toColumns template is recursive. It calls itself $numColumns times
		to split the nodes up.
	-->
	<xsl:template name="toColumns">
		<xsl:param name="nodes" />
		<!-- Each time the toColumns template is called, the segment number is increased by 1 -->
		<xsl:param name="segment">1</xsl:param>
		<!--
			The median is the point at which we switch to the next column.
			(e.g. We have 16 nodes that we wish to split into 3 columns. The median is 6 because that's 16 ÷ 3 rounded up. )
		-->
		<xsl:param name="median" select="ceiling(count($nodes[self::* or normalize-space(.) != '']) div $numColumns)" />

		<!-- Some debugging information can be output as comments if you uncomment below: -->
		<!--
		<xsl:comment>Median: <xsl:value-of select="$median"/></xsl:comment>
		<xsl:comment>Node count: <xsl:value-of select="count($nodes[self::* or normalize-space(.) != ''])"/></xsl:comment>
		<xsl:comment>Node names: <xsl:for-each select="$nodes[self::* or normalize-space(.) != '']"><xsl:value-of select="position()"/>. <xsl:value-of select="name()"/><xsl:if test="name() = ''"><xsl:choose><xsl:when test="normalize-space(.) = ''">text(empty)</xsl:when><xsl:otherwise><xsl:value-of select="concat('text(',normalize-space(.),')')"/></xsl:otherwise></xsl:choose></xsl:if>,</xsl:for-each></xsl:comment>
		-->

		<!-- Every column is output as a <div> with class="column" and id="column-##" where ## is 1 to $numColumns -->
		<div class="column" id="column-{$segment}">
			<!--
				Use the 'copy' mode, which has one template matching all node()s,
				to find the correct set of nodes to copy into _this_ column.
			-->
			<xsl:apply-templates select="$nodes" mode="copy">
				<xsl:with-param name="median" select="$median"/>
				<xsl:with-param name="segment" select="$segment"/>
			</xsl:apply-templates>
		</div>

		<!-- If we're not on the last segment yet, call the toColumns template again for the next column -->
		<xsl:if test="$segment &lt; $numColumns">
			<xsl:call-template name="toColumns">
				<xsl:with-param name="nodes" select="$nodes" />
				<xsl:with-param name="segment" select="$segment + 1" />
				<xsl:with-param name="median" select="$median" />
			</xsl:call-template>
		</xsl:if>
	</xsl:template>
	
	<xsl:template match="node()" mode="copy">
		<xsl:param name="median" />
		<xsl:param name="segment" select="1" />
		<!--
			realPos is calculated so that we don't count nodes that only contain spaces, but the space nodes are still
			copied into the output. realPos is calculated for every node that we're considering copying.

			This process could probably be optimized using EXSLT's dynamic functions, but for simplicity's sake we're
			sticking with straight XSLT here.
		-->
		<xsl:variable name="realPos" select="count(preceding-sibling::node()[self::* or normalize-space(.) != '']) + 1" />
		<xsl:if test="$realPos &lt;= ($median * $segment) and $realPos &gt; ($median * ($segment - 1))">
			<xsl:apply-templates mode="render" select="."/>
		</xsl:if>
	</xsl:template>

	<!--
		Customize the following to control how each node is displayed.
		You could create multiple templates using mode="render" to have
		this XSLT work with Structured Data.
	-->
	<xsl:template match="node()" mode="render">
		<xsl:copy-of select="." />
	</xsl:template>
	
</xsl:stylesheet>
