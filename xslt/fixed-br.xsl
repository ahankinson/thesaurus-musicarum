<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet
        version="2.0"
        xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
        xmlns:tei="http://www.tei-c.org/ns/1.0"
        xmlns="http://www.tei-c.org/ns/1.0"
        exclude-result-prefixes="tei">

    <!-- ========================================================= -->
    <!-- Identity transform                                       -->
    <!-- ========================================================= -->
    <xsl:mode on-no-match="shallow-copy"/>

    <!-- ========================================================= -->
    <!-- HTML-style <br/> (no namespace) → TEI <lb/>              -->
    <!-- ========================================================= -->
    <xsl:template match="br">
        <lb/>
    </xsl:template>

    <!-- ========================================================= -->
    <!-- <br/> accidentally in TEI namespace → <lb/>              -->
    <!-- ========================================================= -->
    <xsl:template match="tei:br">
        <lb/>
    </xsl:template>

</xsl:stylesheet>
