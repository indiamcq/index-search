<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:     	index-search.xslt
    # Purpose:  	reformat for presentation.
    # Part of:  	Xrunner - https://github.com/SILAsiaPub/xrunner2
    # Author:   	Ian McQuay <india.mcq@gmail.com>
    # Created:  	2026-06-01; 2026-10-31
    # Copyright:	(c) 2026 Ian McQuay
    # Licence:  	<MIT>
    ################################################################ -->
<xsl:stylesheet version="3.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">
    <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" name="xml"/>
    <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" suppress-indentation="h1 h2 h3 li dd dt td th"/>
    <!--  suppress-indentation="h1 h2 h3 p li dd dt td th"-->
    <!-- <xsl:output method="text" encoding="utf-8" /> -->
    <xsl:include href="index-param.xslt"/>
    <xsl:variable name="researchwords" select="concat('(',$searchwords,')')"/>
    <xsl:variable name="lcsearchwords" select="lower-case($searchwords)"/>
    <xsl:variable name="remultisearchwords" select="concat('(',translate($searchwords,' ','|'),')')"/>
    <xsl:variable name="wd2find" select="tokenize($searchwords,' ')"/>
    <xsl:variable name="wd2findcount" select="count($wd2find)"/>
    <xsl:variable name="found">
        <xsl:choose>
            <xsl:when test="$target = 'every'">
                <xsl:apply-templates select="//collection"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//collection[contains(@group,$target)]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:template match="/*">
        <html lang="en">
            <head>
                <title>
                    <xsl:value-of select="$searchwords"/>
                </title>
                <meta charset='utf-8'/>
                <meta name="viewport" content="width=device-width, initial-scale=1"/>
                <link rel="stylesheet" href="../index-result.css"/>
                <link rel="icon" href="../index-search.ico"/>
            </head>
            <body class="{$format}">
                <xsl:comment select="$remultisearchwords"/>
                <xsl:element name="h1">
                    <xsl:text>Search results for: </xsl:text>
                    <xsl:value-of select="$searchwords"/>
                </xsl:element>
                <xsl:element name="p">The search was a <i><xsl:value-of select="$type"/></i> search of <i><xsl:value-of select="$target"/></i> index and output <i><xsl:value-of select="$format"/></i> format. <xsl:if test="$type != 'multi'"><xsl:text>Note: Empty fields are ommitted.</xsl:text></xsl:if></xsl:element>
                <xsl:apply-templates select="$found/collection" mode="html"/>
            </body>
        </html>
        <!-- <xsl:result-document href="found-phase1.xml" format="xml">
            <xsl:element name="found">
                <xsl:sequence select="$found"/>
            </xsl:element>
        </xsl:result-document> -->
    </xsl:template>
    <xsl:template match="collection|collection[@group = $target]">
        <xsl:copy>
            <xsl:copy-of select="@*"/>
            <xsl:copy-of select="h"/>
            <xsl:apply-templates select="r"/>
        </xsl:copy>
    </xsl:template>
    <xsl:template match="r">
        <xsl:variable name="lctext" select="lower-case(text())"/>
        <xsl:choose>
            <xsl:when test="$type = 'phrase' and contains($lctext,$lcsearchwords)">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:when test="$type = 'multi'">
                <xsl:choose>
                    <xsl:when test="$wd2findcount = 1 and matches(text(),$wd2find[1],'i')">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:when test="$wd2findcount = 2 and matches(text(),$wd2find[1],'i') and matches(text(),$wd2find[2],'i')">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:when test="$wd2findcount = 3 and matches(text(),$wd2find[1],'i') and matches(text(),$wd2find[2],'i') and matches(text(),$wd2find[3],'i')">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:when test="$wd2findcount = 4 and matches($lctext,$wd2find[1],'i') and matches(text(),$wd2find[2],'i') and matches(text(),$wd2find[3],'i') and matches(text(),$wd2find[4],'i')">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:otherwise></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$type = 'regex' and matches(text(),$searchwords,'i')">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:otherwise></xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <xsl:template match="collection" mode="html">
        <xsl:variable name="head" select="tokenize(h/text(),'\t')"/>
        <xsl:if test="count(r) &gt; 0">
            <xsl:element name="div">
                <xsl:attribute name="class">
                    <xsl:text>coll</xsl:text>
                </xsl:attribute>
                <xsl:element name="h2">
                    <xsl:value-of select="@index"/>
                </xsl:element>
                <xsl:choose>
                    <xsl:when test="$format = 'table'">
                        <xsl:element name="table">
                            <xsl:element name="tr">
                                <xsl:for-each select="$head">
                                    <xsl:if test="string-length(.) &gt; 0">
                                        <xsl:element name="th">
                                            <xsl:value-of select="."/>
                                        </xsl:element>
                                    </xsl:if>
                                </xsl:for-each>
                            </xsl:element>
                            <xsl:apply-templates select="r" mode="html-table"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$format = 'para'">
                        <xsl:apply-templates select="r" mode="html-para">
                            <xsl:with-param name="head" select="$head"/>
                        </xsl:apply-templates>
                    </xsl:when>
                    <xsl:when test="$format = 'list'">
                        <xsl:apply-templates select="r" mode="html-list">
                            <xsl:with-param name="head" select="$head"/>
                        </xsl:apply-templates>
                    </xsl:when>
                </xsl:choose>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template match="r" mode="html-table">
        <xsl:element name="tr">
            <xsl:choose>
                <xsl:when test="$type = 'phrase'">
                    <xsl:variable name="markedsearchwords" select="replace(text(),$researchwords,'§$1§','i')"/>
                    <xsl:sequence select="f:tcell($markedsearchwords)"/>
                </xsl:when>
                <xsl:when test="$type = 'multi'">
                    <xsl:variable name="markedsearchwords" select="replace(text(),$remultisearchwords,'§$1§','i')"/>
                    <xsl:sequence select="f:tcell($markedsearchwords)"/>
                </xsl:when>
                <xsl:when test="$type = 'regex'">
                    <xsl:variable name="markedsearchwords" select="replace(text(),$researchwords,'§$1§')"/>
                    <xsl:sequence select="f:tcell($markedsearchwords)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    <xsl:template match="r" mode="html-para">
        <xsl:param name="head"/>
        <xsl:element name="p">
            <xsl:choose>
                <xsl:when test="$type = 'phrase'">
                    <xsl:variable name="markedsearchwords" select="replace(text(),$researchwords,'§$1§','i')"/>
                    <xsl:sequence select="f:pcell($markedsearchwords,$head)"/>
                </xsl:when>
                <xsl:when test="$type = 'multi'">
                    <xsl:variable name="markedsearchwords" select="replace(text(),$remultisearchwords,'§$1§','i')"/>
                    <xsl:sequence select="f:pcell($markedsearchwords,$head)"/>
                </xsl:when>
                <xsl:when test="$type = 'regex'">
                    <xsl:variable name="markedsearchwords" select="replace(text(),$researchwords,'§$1§')"/>
                    <xsl:sequence select="f:pcell($markedsearchwords,$head)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    <xsl:template match="r" mode="html-list">
        <xsl:param name="head"/>
        <xsl:element name="div">
            <xsl:attribute name="class">
                <xsl:text>record</xsl:text>
            </xsl:attribute>
            <xsl:choose>
                <xsl:when test="$type = 'phrase'">
                    <xsl:variable name="markedsearchwords" select="replace(text(),$researchwords,'§$1§','i')"/>
                    <xsl:sequence select="f:listcell($markedsearchwords,$head)"/>
                </xsl:when>
                <xsl:when test="$type = 'multi'">
                    <xsl:variable name="markedsearchwords" select="replace(text(),$remultisearchwords,'§$1§','i')"/>
                    <xsl:sequence select="f:listcell($markedsearchwords,$head)"/>
                </xsl:when>
                <xsl:when test="$type = 'regex'">
                    <xsl:variable name="markedsearchwords" select="replace(text(),$researchwords,'§$1§')"/>
                    <xsl:sequence select="f:listcell($markedsearchwords,$head)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="text()"/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:element>
    </xsl:template>
    <xsl:function name="f:tcell">
        <xsl:param name="string"/>
        <xsl:variable name="cell" select="tokenize($string,'\t')"/>
        <xsl:for-each select="$cell">
            <xsl:element name="td">
                <xsl:sequence select="f:parsemarked(.)"/>
            </xsl:element>
        </xsl:for-each>
    </xsl:function>
    <xsl:function name="f:pcell">
        <xsl:param name="string"/>
        <xsl:param name="head"/>
        <xsl:variable name="cell" select="tokenize($string,'\t')"/>
        <xsl:for-each select="$cell">
            <xsl:variable name="pos" select="position()"/>
            <xsl:if test="string-length(.) &gt; 0">
                <xsl:text> </xsl:text>
                <xsl:element name="span">
                    <xsl:attribute name="class">ptag</xsl:attribute>
                    <xsl:value-of select="$head[$pos]"/>
                    <xsl:text>: </xsl:text>
                </xsl:element>
                <xsl:sequence select="f:parsemarked(.)"/>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    <xsl:function name="f:listcell">
        <xsl:param name="string"/>
        <xsl:param name="head"/>
        <xsl:variable name="cell" select="tokenize($string,'\t')"/>
        <xsl:for-each select="$cell">
            <xsl:variable name="pos" select="position()"/>
            <xsl:if test="string-length(.) &gt; 0">
                <xsl:element name="div">
                    <xsl:element name="span">
                        <xsl:attribute name="class">tag</xsl:attribute>
                        <xsl:value-of select="$head[$pos]"/>
                        <xsl:text>:&#x2003;&#x2003;</xsl:text>
                    </xsl:element>
                    <xsl:element name="span">
                        <xsl:attribute name="class">val</xsl:attribute>
                        <xsl:sequence select="f:parsemarked(.)"/>
                    </xsl:element>
                </xsl:element>
            </xsl:if>
        </xsl:for-each>
    </xsl:function>
    <xsl:function name="f:parsemarked">
        <xsl:param name="markedtext"/>
        <xsl:variable name="match">
            <xsl:choose>
                <xsl:when test="$type = 'phrase'">
                    <xsl:value-of select="$searchwords"/>
                </xsl:when>
                <xsl:when test="$type = 'multi'">
                    <xsl:value-of select="$remultisearchwords"/>
                </xsl:when>
                <xsl:when test="$type = 'regex'">
                    <xsl:value-of select="$researchwords"/>
                </xsl:when>
            </xsl:choose>
        </xsl:variable>
        <xsl:variable name="textarray" select="tokenize($markedtext,'§')"/>
        <xsl:for-each select="$textarray">
            <xsl:choose>
                <xsl:when test="matches(. ,$match,'i')">
                    <xsl:sequence select="f:hilite(.)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:for-each>
    </xsl:function>
    <xsl:function name="f:hilite">
        <xsl:param name="text"/>
        <span>
            <xsl:attribute name="class">
                <xsl:text>hilite</xsl:text>
            </xsl:attribute>
            <xsl:value-of select="$text"/>
        </span>
    </xsl:function>
</xsl:stylesheet>
