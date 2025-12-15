<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

    <!-- ========================================================= -->
    <!-- Identity transform                                       -->
    <!-- ========================================================= -->
    <xsl:mode on-no-match="shallow-copy"/>

    <!-- ========================================================= -->
    <!-- Normalize author and absorb following date               -->
    <!-- ========================================================= -->
    <xsl:template match="tei:titleStmt/tei:author">
        <author>
            <persName>
                <xsl:value-of select="normalize-space(.)"/>
            </persName>
            <xsl:apply-templates select="following-sibling::tei:date[1]"/>
        </author>
    </xsl:template>

    <!-- Remove titleStmt date once absorbed into author -->
    <xsl:template match="tei:titleStmt/tei:date"/>

    <!-- ========================================================= -->
    <!-- Fix editionStmt structure (TEI-valid)                    -->
    <!-- ========================================================= -->
    <xsl:template match="tei:editionStmt">
        <xsl:variable name="editionText" select="normalize-space(text()[normalize-space()][1])"/>

        <editionStmt>
            <edition>
                <xsl:value-of select="$editionText"/>
            </edition>

            <xsl:apply-templates select="tei:respStmt"/>
            <!-- IMPORTANT: no <date> here -->
        </editionStmt>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- Expand TML responsibility codes                          -->
    <!-- ========================================================= -->
    <xsl:template match="tei:resp">
        <resp>
            <xsl:choose>
                <xsl:when test="normalize-space(.) = 'E'">Editor</xsl:when>
                <xsl:when test="normalize-space(.) = 'C'">Corrector</xsl:when>
                <xsl:when test="normalize-space(.) = 'T'">Transcriber</xsl:when>
                <xsl:when test="normalize-space(.) = 'A'">Advisor</xsl:when>
                <xsl:otherwise>
                    <xsl:value-of select="normalize-space(.)"/>
                </xsl:otherwise>
            </xsl:choose>
        </resp>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- Insert publicationStmt if missing (TEI-valid)            -->
    <!-- ========================================================= -->
    <xsl:template match="tei:fileDesc[not(tei:publicationStmt)]">

        <!-- Extract values from the SOURCE tree -->
        <xsl:variable name="publisherText"
            select="normalize-space(tei:editionStmt/text()[normalize-space()][1])"/>

        <xsl:variable name="pubDate" select="normalize-space(tei:editionStmt/tei:date)"/>

        <fileDesc>
            <xsl:apply-templates select="tei:titleStmt"/>
            <xsl:apply-templates select="tei:editionStmt"/>

            <publicationStmt>
                <publisher>
                    <xsl:value-of select="$publisherText"/>
                </publisher>

                <xsl:if test="$pubDate">
                    <date when="{$pubDate}">
                        <xsl:value-of select="$pubDate"/>
                    </date>
                </xsl:if>

                <availability>
                    <p>Distributed for scholarly use.</p>
                </availability>
            </publicationStmt>

            <xsl:apply-templates select="tei:sourceDesc"/>
        </fileDesc>
    </xsl:template>

</xsl:stylesheet>
