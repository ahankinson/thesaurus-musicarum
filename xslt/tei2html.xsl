<xsl:stylesheet
        version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:tei="http://www.tei-c.org/ns/1.0"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        exclude-result-prefixes="tei xs">

    <xsl:output method="html" encoding="UTF-8"/>
    <xsl:strip-space elements="*"/>

    <!-- ========================================================= -->
    <!-- Utility: escape strings for YAML                          -->
    <!-- ========================================================= -->

    <xsl:function name="tei:yaml-escape" as="xs:string">
        <xsl:param name="s" as="xs:string"/>
        <xsl:variable name="norm" select="normalize-space($s)"/>
        <xsl:variable name="esc1" select="replace($norm, '\\', '\\\\')"/>
        <xsl:sequence select="replace($esc1, '&quot;', '\\&quot;')"/>
    </xsl:function>

    <!-- ========================================================= -->
    <!-- Root template                                             -->
    <!-- ========================================================= -->

    <xsl:template match="/">
        <!-- ================= YAML front matter ================= -->

        <xsl:text>---
</xsl:text>

        <!-- Title -->
        <xsl:text>title: "</xsl:text>
        <xsl:value-of select="
    tei:yaml-escape(
      /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:title[not(@type)][1]
    )
  "/>
        <xsl:text>"
</xsl:text>

        <!-- Author -->
        <xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author">
            <xsl:text>source_author: "</xsl:text>
            <xsl:value-of select="
      tei:yaml-escape(
        normalize-space(
          /tei:TEI/tei:teiHeader/tei:fileDesc/tei:titleStmt/tei:author/tei:persName
        )
      )
    "/>
            <xsl:text>"
</xsl:text>
        </xsl:if>

        <!-- Work date -->
        <xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@type='source']/tei:date">
            <xsl:text>source_date: "</xsl:text>
            <xsl:value-of select="
      tei:yaml-escape(
        normalize-space(
          /tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@type='source']/tei:date
        )
      )
    "/>
            <xsl:text>"
</xsl:text>
        </xsl:if>

        <!-- Editors -->
        <xsl:text>
editors:
</xsl:text>
        <xsl:apply-templates
                select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:respStmt[tei:resp='Editor']"
                mode="yaml-list"/>

        <!-- Correctors -->
        <xsl:text>
correctors:
</xsl:text>
        <xsl:apply-templates
                select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:respStmt[tei:resp='Corrector']"
                mode="yaml-list"/>

        <!-- Advisors -->
        <xsl:text>
advisor:
</xsl:text>
        <xsl:apply-templates
                select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:editionStmt/tei:respStmt[tei:resp='Advisor']"
                mode="yaml-list"/>

        <!-- Witnesses (only if present) -->
        <xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit/tei:witness">
    <xsl:text>
witnesses:
</xsl:text>
            <xsl:apply-templates
                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit/tei:witness"
                    mode="yaml-witness"/>
        </xsl:if>

        <xsl:text>
---
</xsl:text>

        <!-- ================= Render TEI text ================= -->

        <div class="tei-text">
            <xsl:apply-templates select="/tei:TEI/tei:text"/>
        </div>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- YAML helpers                                              -->
    <!-- ========================================================= -->

    <xsl:template match="tei:respStmt" mode="yaml-list">
        <xsl:text>  - "</xsl:text>
        <xsl:value-of select="tei:yaml-escape(normalize-space(tei:persName))"/>
        <xsl:text>"
</xsl:text>
    </xsl:template>

    <xsl:template match="tei:witness" mode="yaml-witness">
        <xsl:text>  - idno: "</xsl:text>
        <xsl:value-of select="tei:yaml-escape(normalize-space(tei:idno))"/>
        <xsl:text>"
</xsl:text>
        <xsl:text>    type: "</xsl:text>
        <xsl:value-of select="tei:yaml-escape(normalize-space(tei:idno/@type))"/>
        <xsl:text>"
</xsl:text>
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
            <xsl:if test="@xml:id">
                <xsl:attribute name="id">
                    <xsl:value-of select="@xml:id"/>
                </xsl:attribute>
            </xsl:if>
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

    <xsl:template match="tei:pb">
        <xsl:if test="@n">
            <sup class="pb">
                <xsl:value-of select="@n"/>
            </sup>
        </xsl:if>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- Text nodes                                                -->
    <!-- ========================================================= -->

    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- Suppressed sections                                       -->
    <!-- ========================================================= -->

    <xsl:template match="tei:teiHeader"/>
    <xsl:template match="tei:facsimile"/>
    <xsl:template match="tei:standOff"/>

</xsl:stylesheet>
