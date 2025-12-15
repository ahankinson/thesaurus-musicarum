<xsl:stylesheet version="2.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <!-- Identity transform -->
  <xsl:mode on-no-match="shallow-copy"/>

  <!-- Rename @id to @xml:id -->
  <xsl:template match="@id">
    <xsl:attribute name="xml:id" namespace="http://www.w3.org/XML/1998/namespace">
      <xsl:value-of select="."/>
    </xsl:attribute>
  </xsl:template>

</xsl:stylesheet>
