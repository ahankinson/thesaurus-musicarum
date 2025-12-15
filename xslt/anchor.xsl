<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
    xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns="http://www.tei-c.org/ns/1.0"
    exclude-result-prefixes="tei">

    <!-- Identity transform -->
    <xsl:mode on-no-match="shallow-copy"/>

    <!-- Replace HTML-style anchor with TEI anchor -->
    <xsl:template match="tei:a[@name]">
        <anchor xml:id="{@xml:id}"/>
    </xsl:template>

</xsl:stylesheet>
