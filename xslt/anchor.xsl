<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:tei="http://www.tei-c.org/ns/1.0"
        xmlns="http://www.tei-c.org/ns/1.0"
        exclude-result-prefixes="tei">

    <!-- Identity transform -->
    <xsl:mode on-no-match="shallow-copy"/>

    <!-- 1. HTML-style anchor used as milestone -->
    <xsl:template match="tei:a[@name]">
        <anchor xml:id="{@xml:id}"/>
    </xsl:template>

    <!-- 2. HTML-style hyperlink -->
    <xsl:template match="tei:a[@href]">
        <ref target="{@href}">
            <xsl:apply-templates/>
        </ref>
    </xsl:template>

    <!-- 3. Bare <a> element (no attributes) -->
    <xsl:template match="tei:a[not(@*)]">
        <ref>
            <xsl:apply-templates/>
        </ref>
    </xsl:template>

</xsl:stylesheet>
