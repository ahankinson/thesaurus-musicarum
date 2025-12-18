<xsl:stylesheet
        version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:tei="http://www.tei-c.org/ns/1.0"
        xmlns:xs="http://www.w3.org/2001/XMLSchema"
        exclude-result-prefixes="tei xs">

    <xsl:output
            method="xml"
            encoding="UTF-8"
            indent="no"
            omit-xml-declaration="yes"/>
    <xsl:strip-space elements="*"/>

    <!-- ========================================================= -->
    <!-- Utility: escape strings for YAML (quoted scalars only)    -->
    <!-- ========================================================= -->

    <xsl:function name="tei:yaml-escape" as="xs:string">
        <xsl:param name="s" as="xs:string"/>
        <xsl:variable name="norm" select="normalize-space($s)"/>
        <xsl:variable name="esc1" select="replace($norm, '\\', '\\\\')"/>
        <xsl:sequence select="replace($esc1, '&quot;', '\\&quot;')"/>
    </xsl:function>

    <!-- ========================================================= -->
    <!-- Utility: extract zero-padded sort key from date           -->
    <!-- ========================================================= -->

    <xsl:function name="tei:date-sort-key" as="xs:string">
        <xsl:param name="date" as="xs:string?"/>

        <xsl:variable name="digits"
                      select="replace(normalize-space($date), '^.*?([0-9]+).*$','$1')"/>

        <xsl:variable name="n"
                      select="if (matches($digits, '^[0-9]+$'))
                    then xs:integer($digits)
                    else 999"/>

        <xsl:sequence select="format-number($n, '000')"/>
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
            )"/>
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
                )"/>
            <xsl:text>"
</xsl:text>
        </xsl:if>

        <!-- Source date + sort key -->
        <xsl:variable name="source-date"
                      select="normalize-space(
                /tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc
                /tei:bibl[@type='source']/tei:date
            )"/>

        <xsl:if test="$source-date">
            <xsl:text>source_date: "</xsl:text>
            <xsl:value-of select="tei:yaml-escape($source-date)"/>
            <xsl:text>"
</xsl:text>

            <xsl:text>source_date_sort: "</xsl:text>
            <xsl:value-of select="tei:date-sort-key($source-date)"/>
            <xsl:text>"
</xsl:text>
        </xsl:if>

        <!-- Edition (HTML block scalar) -->
        <xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@type='edition']">
            <xsl:text>
edition: |
</xsl:text>
            <xsl:apply-templates
                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:bibl[@type='edition']"
                    mode="yaml-edition"/>
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

        <!-- Witnesses -->
        <xsl:if test="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit/tei:witness">
            <xsl:text>
witnesses:
</xsl:text>
            <xsl:apply-templates
                    select="/tei:TEI/tei:teiHeader/tei:fileDesc/tei:sourceDesc/tei:listWit/tei:witness"
                    mode="yaml-witness"/>
        </xsl:if>

        <xsl:text>
markup: html
---
</xsl:text>

        <!-- ================= Render TEI text ================= -->

        <div class="tei-text">
            <xsl:apply-templates select="/tei:TEI/tei:text"/>
        </div>

    </xsl:template>

    <!-- ========================================================= -->
    <!-- YAML helper templates                                     -->
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

    <!-- Edition serialization -->
    <xsl:template match="tei:bibl[@type='edition']" mode="yaml-edition">
        <xsl:text>    </xsl:text>
        <xsl:apply-templates select="node()" mode="yaml-edition-inline"/>
        <xsl:text>&#10;</xsl:text>
    </xsl:template>

    <xsl:template match="tei:emph" mode="yaml-edition-inline">
        <em>
            <xsl:apply-templates mode="yaml-edition-inline"/>
        </em>
        <xsl:text> </xsl:text>
    </xsl:template>

    <xsl:template match="text()" mode="yaml-edition-inline">
        <xsl:value-of select="replace(normalize-space(.), '\s+', ' ')"/>
        <xsl:text> </xsl:text>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- TEI body rendering                                        -->
    <!-- ========================================================= -->

    <xsl:template match="tei:text | tei:front | tei:body | tei:back">
        <xsl:apply-templates/>
    </xsl:template>

    <xsl:template match="tei:div">
        <div><xsl:apply-templates/></div>
    </xsl:template>

    <xsl:template match="tei:head">
        <h2><xsl:apply-templates/></h2>
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

    <xsl:template match="tei:hi">
        <span><xsl:apply-templates/></span>
    </xsl:template>

    <xsl:template match="tei:lb">
        <br/>
    </xsl:template>

    <xsl:template match="tei:pb">
        <xsl:if test="@n">
            <sup class="pb"><xsl:value-of select="@n"/></sup>
        </xsl:if>
    </xsl:template>

    <!-- Default text -->
    <xsl:template match="text()">
        <xsl:value-of select="."/>
    </xsl:template>

    <!-- Suppressed sections -->
    <xsl:template match="tei:teiHeader"/>
    <xsl:template match="tei:facsimile"/>
    <xsl:template match="tei:standOff"/>

</xsl:stylesheet>
