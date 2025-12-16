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
    <!-- Convert p@class='textFig' → figure                        -->
    <!-- ========================================================= -->
    <xsl:template match="tei:p[@class = 'textFig']">
        <figure xml:id="{@xml:id}">
            <p>
                <xsl:apply-templates/>
            </p>
        </figure>
    </xsl:template>

</xsl:stylesheet>
