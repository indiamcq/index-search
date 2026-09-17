<?xml version="1.0" encoding="utf-8"?>
<!--
    #############################################################
    # Name:     	present-search.xslt
    # Purpose:  	reformat for presentation.
    # Part of:  	Xrunner - https://github.com/SILAsiaPub/xrunner2
    # Author:   	Ian McQuay <ian_mcquay@sil.org>
    # Created:  	2026-06-01
    # Copyright:	(c) 2026 SIL International
    # Licence:  	<MIT>
    ################################################################ -->
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:f="myfunctions" exclude-result-prefixes="f">
    <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" name="xml"/>
    <xsl:output method="xml" version="1.0" encoding="utf-8" omit-xml-declaration="no" indent="yes" suppress-indentation="h1 h2 h3 p li dd dt td th"/>
    <!--  suppress-indentation="h1 h2 h3 p li dd dt td th"-->
    <!-- <xsl:output method="text" encoding="utf-8" /> -->
    <!-- <xsl:include href="project.xslt"/> -->
    <!-- <xsl:param name="searchword"/> -->
    <xsl:param name="type"/>
    <xsl:param name="searchword"/>
    <xsl:param name="nosp"/>
    <xsl:param name="target"/>
    <xsl:param name="output"/>
    <xsl:variable name="spacedsearchwordsulc" select="translate($searchword,$nosp,' ')"/>
    <xsl:variable name="spacedsearchwords" select="lower-case(translate($searchword,$nosp,' '))"/>
    <xsl:variable name="regexsearchwords" select="translate($searchword,$nosp,' ')"/>
    <xsl:variable name="wd2find" select="tokenize($spacedsearchwords,' ')"/>
    <xsl:variable name="wd2findcount" select="count($wd2find)"/>
    <xsl:variable name="found">
        <xsl:choose>
            <xsl:when test="$target = 'every'">
                <xsl:apply-templates select="//collection"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:apply-templates select="//collection[@group = $target]"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:variable>
    <xsl:template match="/*">
        <html lang="en">
            <head>
                <title>
                    <xsl:value-of select="$searchword"/>
                </title>
                <meta charset='utf-8'/>
                <meta name="viewport" content="width=device-width, initial-scale=1"/>
                <link rel="stylesheet" href="../result.css"/>
            </head>
            <body>
                <xsl:element name="h1">
                    <xsl:text>Search results for: </xsl:text>
                    <xsl:value-of select="replace($searchword,$nosp,' ')"/>
                    <xsl:apply-templates select="$found/collection" mode="html"/>
                </xsl:element>
            </body>
        </html>
        <xsl:result-document href="found.xml" format="xml">
            <xsl:element name="found">
                <xsl:sequence select="$found"/>
            </xsl:element>
        </xsl:result-document>
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
            <xsl:when test="$type = 'phrase' and contains($lctext,$spacedsearchwords)">
                <xsl:copy-of select="."/>
            </xsl:when>
            <xsl:when test="$type = 'multi'">
                <xsl:choose>
                    <xsl:when test="$wd2findcount = 1 and contains($lctext,$wd2find[1])">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:when test="$wd2findcount = 2 and contains($lctext,$wd2find[1]) and contains($lctext,$wd2find[2])">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:when test="$wd2findcount = 3 and contains($lctext,$wd2find[1]) and contains($lctext,$wd2find[2]) and contains($lctext,$wd2find[3])">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:when test="$wd2findcount = 4 and contains($lctext,$wd2find[1]) and contains($lctext,$wd2find[2]) and contains($lctext,$wd2find[3]) and contains($lctext,$wd2find[4])">
                        <xsl:copy-of select="."/>
                    </xsl:when>
                    <xsl:otherwise></xsl:otherwise>
                </xsl:choose>
            </xsl:when>
            <xsl:when test="$type = 'regex' and matches(text(),$regexsearchwords)">
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
                    <xsl:when test="$output = 'table'">
                        <xsl:element name="table">
                            <xsl:element name="tr">
                                <xsl:for-each select="$head">
                                    <xsl:element name="th">
                                        <xsl:value-of select="."/>
                                    </xsl:element>
                                </xsl:for-each>
                            </xsl:element>
                            <xsl:apply-templates select="r" mode="html"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:apply-templates select="r" mode="html">
                            <xsl:with-param name="head" select="$head"/>
                        </xsl:apply-templates>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:element>
        </xsl:if>
    </xsl:template>
    <xsl:template match="r" mode="html">
        <xsl:param name="head"/>
        <xsl:variable name="cell" select="tokenize(.,'\t')"/>
        <xsl:choose>
            <xsl:when test="$output = 'table'">
                <xsl:sequence select="f:tcell($cell)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="f:cell($head,$cell)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:template>
    <!--     <xsl:function name="f:multifind">
        <xsl:param name="text"/>
        <xsl:param name="wd2find"/>
        <xsl:param name="testseq"/>
        <xsl:param name="count"/>
        <xsl:choose>
            <xsl:when test="$testseq &gt;= count($wd2find)">
                <xsl:value-of select="$count"/>
            </xsl:when>
            <xsl:when test="contains($text,$wd2find[$testseq])">
                <xsl:value-of select="f:multifind($text,$wd2find,$testseq + 1,$count + 1)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="f:multifind(lower-case($text),$wd2find,$testseq + 1,$count)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function> -->
    <xsl:function name="f:cell">
        <xsl:param name="head"/>
        <xsl:param name="cell"/>
        <xsl:element name="p">
            <xsl:for-each select="$cell">
                <xsl:variable name="pos" select="position()"/>
                <xsl:element name="span">
                    <xsl:attribute name="class">
                        <xsl:text>label</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="$head[$pos]"/>
                </xsl:element>
                <xsl:value-of select="."/>
                <xsl:text>&#x2002;</xsl:text>
            </xsl:for-each>
        </xsl:element>
    </xsl:function>
    <xsl:function name="f:tcell">
        <xsl:param name="tcell"/>
        <xsl:element name="tr">
            <xsl:for-each select="$tcell">
                <xsl:variable name="lctext" select="lower-case(.)"/>
                <xsl:choose>
                    <xsl:when test="$type = 'multi' and $wd2findcount = 1 and  contains($lctext,$wd2find[1])">
                        <xsl:element name="td">
                            <xsl:attribute name="class">
                                <xsl:text>hilight</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$type = 'multi' and $wd2findcount = 2 and (contains($lctext,$wd2find[1]) or contains($lctext,$wd2find[2]))">
                        <xsl:element name="td">
                            <xsl:attribute name="class">
                                <xsl:text>hilight</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$type = 'multi' and $wd2findcount = 3 and (contains($lctext,$wd2find[1]) or contains($lctext,$wd2find[2]) or contains($lctext,$wd2find[3]))">
                        <xsl:element name="td">
                            <xsl:attribute name="class">
                                <xsl:text>hilight</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$type = 'multi' and $wd2findcount = 4 and (contains($lctext,$wd2find[1]) or contains($lctext,$wd2find[2]) or contains($lctext,$wd2find[3]) or contains($lctext,$wd2find[4]))">
                        <xsl:element name="td">
                            <xsl:attribute name="class">
                                <xsl:text>hilight</xsl:text>
                            </xsl:attribute>
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$type = 'regex' and matches(.,$regexsearchwords)">
                        <xsl:variable name="re" select="concat('.*(',$regexsearchwords,').*')"/>
                        <xsl:variable name="restring" select="replace(.,$re,'$1')"/>
                        <xsl:element name="td">
                            <xsl:sequence select="f:hilite(.,$restring)"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$type = 'phrase' and contains(.,$spacedsearchwordsulc)">
                        <xsl:element name="td">
                            <xsl:sequence select="f:hilite(.,$spacedsearchwordsulc)"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:when test="$type = 'phrase' and contains($lctext,$spacedsearchwords)">
                        <xsl:element name="td">
                            <xsl:sequence select="f:hilite(.,$spacedsearchwords)"/>
                        </xsl:element>
                    </xsl:when>
                    <xsl:otherwise>
                        <xsl:element name="td">
                            <xsl:value-of select="."/>
                        </xsl:element>
                    </xsl:otherwise>
                </xsl:choose>
            </xsl:for-each>
        </xsl:element>
    </xsl:function>
    <xsl:function name="f:hilite">
        <xsl:param name="text"/>
        <xsl:param name="search-string"/>
        <xsl:choose>
            <xsl:when test="contains($text, $search-string)">
                <xsl:value-of select="substring-before($text, $search-string)"/>
                <span>
                    <xsl:attribute name="class">
                        <xsl:text>hilite</xsl:text>
                    </xsl:attribute>
                    <xsl:value-of select="$search-string"/>
                </span>
                <xsl:sequence select="f:hilite(substring-after($text, $search-string),$search-string)"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:value-of select="$text"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <!-- 
    <xsl:function name="f:cntfind">
        <xsl:param name="array"/>
        <xsl:param name="find"/>
        <xsl:param name="count"/>
        <xsl:param name="result"/>
        <xsl:choose>
            <xsl:when test="contains($array[number($count)],$find)">
                <xsl:value-of select="1"/>
            </xsl:when>
            <xsl:when test="$count = count($array)">
                <xsl:value-of select="$result"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="f:cntfind($array,$find,$count +1,$result)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="f:cntfindRE">
        <xsl:param name="array"/>
        <xsl:param name="find"/>
        <xsl:param name="count"/>
        <xsl:param name="result"/>
        <xsl:choose>
            <xsl:when test="matches($array[number($count)],$find)">
                <xsl:value-of select="1"/>
            </xsl:when>
            <xsl:when test="$count = count($array)">
                <xsl:value-of select="$result"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="f:cntfindRE($array,$find,$count +1,$result)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function>
    <xsl:function name="f:cntfindMulti">
        <xsl:param name="array"/>
        <xsl:param name="find"/>
        <xsl:param name="count"/>
        <xsl:param name="result"/>
        <xsl:variable name="result2">
            <xsl:for-each select="$array">
                <xsl:value-of select="f:multifind(.,$find,1,0)"/>
            </xsl:for-each>
        </xsl:variable>
        <xsl:choose>
            <xsl:when test="$result2 &gt;= count($wd2find)">
                <xsl:value-of select="$result2"/>
            </xsl:when>
            <xsl:when test="$count = count($array)">
                <xsl:value-of select="$result"/>
            </xsl:when>
            <xsl:otherwise>
                <xsl:sequence select="f:cntfindMulti($array,$find,$count + 1,$result2)"/>
            </xsl:otherwise>
        </xsl:choose>
    </xsl:function> -->
</xsl:stylesheet>
