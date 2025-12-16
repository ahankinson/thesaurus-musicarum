<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:tei="http://www.tei-c.org/ns/1.0"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        xmlns="http://www.tei-c.org/ns/1.0"
        exclude-result-prefixes="tei xs">

    <!-- ========================================================= -->
    <!-- Identity transform                                       -->
    <!-- ========================================================= -->
    <xsl:mode on-no-match="shallow-copy"/>

    <!-- ========================================================= -->
    <!-- Helper function: pad year values to four digits           -->
    <!-- ========================================================= -->
    <xsl:function name="tei:pad-year" as="xs:string">
        <xsl:param name="y" as="xs:string"/>
        <xsl:sequence select="format-number(number($y), '0000')"/>
    </xsl:function>

    <!-- ========================================================= -->
    <!-- Normalize year-valued date attributes globally            -->
    <!-- ========================================================= -->
    <xsl:template match="@when | @notBefore | @notAfter">
        <xsl:attribute name="{name()}">
            <xsl:choose>
                <xsl:when test="matches(., '^\d{1,4}$')">
                    <xsl:value-of select="tei:pad-year(.)"/>
                </xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="."/>
                </xsl:otherwise>
            </xsl:choose>
        </xsl:attribute>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- Expand TML responsibility codes                           -->
    <!-- ========================================================= -->
    <xsl:template match="tei:resp">
        <resp>
            <xsl:choose>
                <xsl:when test="normalize-space(.) = 'E'">Editor</xsl:when>
                <xsl:when test="normalize-space(.) = 'C'">Corrector</xsl:when>
                <xsl:when test="normalize-space(.) = 'A'">Advisor</xsl:when>
                <xsl:when test="normalize-space(.) = 'T'">Transcriber</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </resp>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- Rewrite fileDesc                                         -->
    <!-- ========================================================= -->
    <xsl:template match="tei:fileDesc">

        <!-- Local variables (context-safe) -->
        <xsl:variable name="titleStmt" select="tei:titleStmt"/>
        <xsl:variable name="editionStmt" select="tei:editionStmt"/>

        <xsl:variable name="workTitle"
                      select="normalize-space($titleStmt/tei:title[1])"/>

        <xsl:variable name="workAuthor"
                      select="normalize-space($titleStmt/tei:author)"/>

        <xsl:variable name="workDate"
                      select="$titleStmt/tei:date"/>

        <xsl:variable name="editionName"
                      select="normalize-space($editionStmt/text()[normalize-space()][1])"/>

        <xsl:variable name="pubYear"
                      select="normalize-space($editionStmt/tei:date)"/>

        <fileDesc>

            <!-- ================= titleStmt ================= -->
            <titleStmt>
                <xsl:apply-templates select="$titleStmt/tei:title"/>
                <author>
                    <persName>
                        <xsl:value-of select="$workAuthor"/>
                    </persName>
                </author>
            </titleStmt>

            <!-- ================= editionStmt ================= -->
            <editionStmt>
                <edition>
                    <xsl:value-of select="$editionName"/>
                </edition>
                <xsl:apply-templates select="$editionStmt/tei:respStmt"/>
            </editionStmt>

            <!-- ================= publicationStmt ================= -->
            <publicationStmt>
                <publisher>Thesaurus Musicarum Latinarum</publisher>

                <xsl:if test="$pubYear">
                    <date when="{tei:pad-year($pubYear)}">
                        <xsl:value-of select="$pubYear"/>
                    </date>
                </xsl:if>

                <availability>
                    <p>Distributed for scholarly use.</p>
                </availability>
            </publicationStmt>

            <!-- ================= sourceDesc ================= -->
            <sourceDesc>

                <bibl type="source">
                    <title>
                        <xsl:value-of select="$workTitle"/>
                    </title>

                    <!-- recreate work date so attribute templates fire -->
                    <xsl:if test="$workDate">
                        <date>
                            <xsl:apply-templates select="$workDate/@*"/>
                            <xsl:value-of select="$workDate"/>
                        </date>
                    </xsl:if>

                    <author>
                        <persName>
                            <xsl:value-of select="$workAuthor"/>
                        </persName>
                    </author>
                </bibl>

                <!-- preserve existing bibliographic structures -->
                <xsl:apply-templates
                        select="tei:sourceDesc/tei:bibl[@type=('edition','work')]
                | tei:sourceDesc/tei:listWit"/>

            </sourceDesc>

        </fileDesc>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- Suppress legacy dates in old locations                   -->
    <!-- ========================================================= -->
    <xsl:template match="tei:titleStmt/tei:date"/>
    <xsl:template match="tei:editionStmt/tei:date"/>

</xsl:stylesheet>
