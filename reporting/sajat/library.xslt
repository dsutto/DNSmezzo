<?xml version='1.0' encoding='UTF-8'?>
<xsl:stylesheet version="1.0"
xmlns:tal="http://xml.zope.org/namespaces/tal"
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
    <link rel="stylesheet" type="text/css" href="style/mezzo.css" />

    <style type="text/css">
      ul {
        list-style-type: none;
      }
    </style>

  </head>
  <body>
    <div class="container">
      <div id="header" class="span-24 last">
        <div id="header_left" class="span-7">
          <img src="img/domain.png" alt="" />
        </div>
        <div id="header_center" class="span-11">
          <h1 class="prepend-1">.hu DNS statisztikák</h1>
        </div>
        <div id="header_right" class="span-6 last">
          <img src="img/stat.png" alt="" class="prepend-3" />
        </div>
        <hr class="mid" />
      </div>
      <div class="content span-24 last">
        <div class="top_menu span-24 last">
          <ul id="mainmenu" class="mainmenu">
            <li><a href="../../../index.php">Naptár</a></li>
            <li><a href="../../../rrd.php">RRD grafikonok</a></li>
            <li><a href="../../../run.php">Jelentések kezelése</a></li>
            <li><a href="../../../table.php">Új táblázatos lekérdezés</a></li>
            <li><a href="../../../image.php">Új grafikonos lekérdezés</a></li>
          </ul>
        </div>


       <div class="span-1"><p></p></div>
       <div class="span-22 last">
        <h2><xsl:value-of select="page/@pagetitle" /></h2>
	<xsl:if test="page/@pagesubtitle!=&quot;&quot;">
          <h3><xsl:value-of select="page/@pagesubtitle" /></h3>
	</xsl:if>
       <xsl:copy-of select="page/*" />
       </div>
       <div class="span-1 last"><p></p></div>
      </div>
    </div>
  </body>
  </html>
</xsl:template>


</xsl:stylesheet>
