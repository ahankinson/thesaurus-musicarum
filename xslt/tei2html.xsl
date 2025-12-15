<xsl:stylesheet
        version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:tei="http://www.tei-c.org/ns/1.0"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        exclude-result-prefixes="tei xs">

    <xsl:output method="html" encoding="UTF-8"/>

    <!-- IMPORTANT: remove indentation whitespace -->
    <xsl:strip-space elements="*"/>

    <!-- ========================================================= -->
    <!-- Utility: escape strings for YAML front matter             -->
    <!-- ========================================================= -->

    <xsl:function name="tei:yaml-escape" as="xs:string">
        <xsl:param name="s" as="xs:string"/>

        <!-- normalize whitespace -->
        <xsl:variable name="norm" select="normalize-space($s)"/>

        <!-- escape backslashes -->
        <xsl:variable name="esc1" select="replace($norm, '\\', '\\\\')"/>

        <!-- escape double quotes -->
        <xsl:sequence select="replace($esc1, '&quot;', '\\&quot;')"/>
    </xsl:function>

    <!-- ========================================================= -->
    <!-- Entry point: ONLY the TEI <text>                           -->
    <!-- ========================================================= -->

    <xsl:template match="/">
        <!-- YAML front matter -->
        <xsl:text>---</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>title: "</xsl:text>
        <xsl:value-of select="
            tei:yaml-escape(
                /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[1]
            )
        "/>
        <xsl:text>"</xsl:text>
        <xsl:text>&#10;</xsl:text>
        <xsl:text>---</xsl:text>
        <xsl:text>&#10;&#10;</xsl:text>

        <!-- Render TEI text -->
        <div class="tei-text">
            <xsl:apply-templates select="/tei:TEI/tei:text"/>
        </div>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- Structural containers                                     -->
    <!-- ========================================================= -->

    <xsl:template match="tei:text | tei:front | tei:body | tei:back">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:div">
        <div>
            <xsl:apply-templates/>
        </div>
    </xsl:template>

    <xsl:template match="tei:head">
        <h2>
            <xsl:apply-templates/>
        </h2>
    </xsl:template>

    <xsl:template match="tei:p">
        <p>
            <xsl:apply-templates/>
        </p>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- Inline elements                                           -->
    <!-- ========================================================= -->

    <xsl:template match="tei:hi">
        <span>
            <xsl:apply-templates/>
        </span>
    </xsl:template>

    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>

    <!-- Suppress page breaks for now -->
    <xsl:template match="tei:pb"/>

    <!-- ========================================================= -->
    <!-- Text nodes                                                -->
    <!-- ========================================================= -->

    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- Suppress non-textual sections                              -->
    <!-- ========================================================= -->

    <xsl:template match="tei:teiHeader"/>
    <xsl:template match="tei:facsimile"/>
    <xsl:template match="tei:standOff"/>

</xsl:stylesheet>
