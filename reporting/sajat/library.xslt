<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version="1.0"
xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

<xsl:template match="/">
  <html>
  <head>
    <title><xsl:value-of select="page/@title" /> | <xsl:value-of select="$projectname" /></title>
    <link rel="stylesheet" href="blueprint/screen.css" type="text/css" media="screen, projection" />
    <link rel="stylesheet" href="blueprint/print.css" type="text/css" media="print" /> 
    <!--[if lt IE 8]>
      <link rel="stylesheet" href="blueprint/ie.css" type="text/css" media="screen, projection">
    <![endif]-->

    <style type="text/css">
      ul {
        list-style-type: none;
      }
    </style>

  </head>
  <body>
    <div class="container">
      <div id="header" class="span-24 last">
        <div id="header_left" class="span-8">
          <img src="img/domain.png" alt="" />
        </div>
        <div id="header_left" class="span-10">
          <h1 class="prepend-1">.hu DNS statisztikák</h1>
        </div>
        <div id="header_left" class="span-6 last">
          <img src="img/stat.png" alt="" class="prepend-3" />
        </div>
        <hr />
      </div>

      <div class="box">
        <h2><xsl:value-of select="page/@pagetitle" /></h2>
	<xsl:if test="page/@pagesubtitle!=&quot;&quot;">
          <h3><xsl:value-of select="page/@pagesubtitle" /></h3>
	</xsl:if>
      <xsl:copy-of select="page" disable-output-escaping="yes" />
      <p>Utoljára módosíta: <xsl:value-of select="page/@lastmod" /></p>
      </div>
    </div>
  </body>
  </html>
</xsl:template>


</xsl:stylesheet>
