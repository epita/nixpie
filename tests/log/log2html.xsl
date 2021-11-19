<?xml version="1.0"?>

<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform">

  <xsl:output method='html' encoding="UTF-8"
              doctype-public="-//W3C//DTD HTML 4.01//EN"
              doctype-system="http://www.w3.org/TR/html4/strict.dtd" />

  <xsl:template match="logfile">
    <html>
      <head>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jquery/1.11.3/jquery.min.js" integrity="sha512-ju6u+4bPX50JQmgU97YOGAXmRMrD9as4LE05PdC3qycsGQmjGlfm041azyB1VfCXpkpt1i9gqXCT6XuxhBJtKg==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
        <script src="https://cdnjs.cloudflare.com/ajax/libs/jqueryui/1.11.4/jquery-ui.min.js" integrity="sha512-BHDCWLtdp0XpAFccP2NifCbJfYoYhsRSZOUM3KnAxy2b/Ay3Bn91frud+3A95brA4wDWV3yEOZrJqgV8aZRXUQ==" crossorigin="anonymous" referrerpolicy="no-referrer"></script>
        <script type="text/javascript">
          $(document).ready(function() {
              /* When a toggle is clicked, show or hide the subtree. */
              $(".logTreeToggle").click(function() {
                  if ($(this).siblings("ul:hidden").length != 0) {
                      $(this).siblings("ul").show();
                      $(this).text("-");
                  } else {
                      $(this).siblings("ul").hide();
                      $(this).text("+");
                  }
              });

              /* Implementation of the expand all link. */
              $(".logTreeExpandAll").click(function() {
                  $(".logTreeToggle", $(this).parent().siblings(".toplevel")).map(function() {
                      $(this).siblings("ul").show();
                      $(this).text("-");
                  });
              });

              /* Implementation of the collapse all link. */
              $(".logTreeCollapseAll").click(function() {
                  $(".logTreeToggle", $(this).parent().siblings(".toplevel")).map(function() {
                      $(this).siblings("ul").hide();
                      $(this).text("+");
                  });
              });
          });
        </script>
        <style>
          body {
              font-family: sans-serif;
              background: white;
          }

          h1
          {
              color: #005aa0;
              font-size: 180%;
          }

          a {
              text-decoration: none;
          }


          ul.nesting, ul.toplevel {
              padding: 0;
              margin: 0;
          }

          ul.toplevel {
              list-style-type: none;
          }

          .line, .head {
              padding-top: 0em;
          }

          ul.nesting li.line, ul.nesting li.lastline {
              position: relative;
              list-style-type: none;
          }

          ul.nesting li.line {
              padding-left: 2.0em;
          }

          ul.nesting li.lastline {
              padding-left: 2.1em; /* for the 0.1em border-left in .lastline > .lineconn */
          }

          li.line {
              border-left: 0.1em solid #6185a0;
          }

          li.line > span.lineconn, li.lastline > span.lineconn {
              position: absolute;
              height: 0.65em;
              left: 0em;
              width: 1.5em;
              border-bottom: 0.1em solid #6185a0;
          }

          li.lastline > span.lineconn {
              border-left: 0.1em solid #6185a0;
          }


          em.storeref {
              color: #500000;
              position: relative;
              width: 100%;
          }

          em.storeref:hover {
              background-color: #eeeeee;
          }

          *.popup {
              display: none;
          /*    background: url('http://losser.st-lab.cs.uu.nl/~mbravenb/menuback.png') repeat; */
              background: #ffffcd;
              border: solid #555555 1px;
              position: absolute;
              top: 0em;
              left: 0em;
              margin: 0;
              padding: 0;
              z-index: 100;
          }

          em.storeref:hover span.popup {
              display: inline;
              width: 40em;
          }


          .logTreeToggle {
              text-decoration: none;
              font-family: monospace;
              font-size: larger;
          }

          .errorLine {
              color: #ff0000;
              font-weight: bold;
          }

          .warningLine {
              color: darkorange;
              font-weight: bold;
          }

          .prio3 {
              font-style: italic;
          }

          code {
              white-space: pre-wrap;
          }

          .serial {
              color: #56115c;
          }

          .machine {
              color: #002399;
              font-style: italic;
          }

          ul.vmScreenshots {
              padding-left: 1em;
          }

          ul.vmScreenshots li {
              font-family: monospace;
              list-style: square;
          }
        </style>
        <title>Log File</title>
      </head>
      <body>
        <h1>VM build log</h1>
        <p>
          <a href="javascript:" class="logTreeExpandAll">Expand all</a> |
          <a href="javascript:" class="logTreeCollapseAll">Collapse all</a>
        </p>
        <ul class='toplevel'>
          <xsl:for-each select='line|nest'>
            <li>
              <xsl:apply-templates select='.'/>
            </li>
          </xsl:for-each>
        </ul>

        <xsl:if test=".//*[@image]">
          <h1>Screenshots</h1>
          <ul class="vmScreenshots">
            <xsl:for-each select='.//*[@image]'>
              <li><a href="{@image}"><xsl:value-of select="@image" /></a></li>
            </xsl:for-each>
          </ul>
        </xsl:if>

      </body>
    </html>
  </xsl:template>


  <xsl:template match="nest">

    <!-- The tree should be collapsed by default if all children are
         unimportant or if the header is unimportant. -->
    <xsl:variable name="collapsed" select="not(./head[@expanded]) and count(.//*[@error]) = 0"/>

    <xsl:variable name="style"><xsl:if test="$collapsed">display: none;</xsl:if></xsl:variable>

    <xsl:if test="line|nest">
      <a href="javascript:" class="logTreeToggle">
        <xsl:choose>
          <xsl:when test="$collapsed"><xsl:text>+</xsl:text></xsl:when>
          <xsl:otherwise><xsl:text>-</xsl:text></xsl:otherwise>
        </xsl:choose>
      </a>
      <xsl:text> </xsl:text>
    </xsl:if>

    <xsl:apply-templates select='head'/>

    <!-- Be careful to only generate <ul>s if there are <li>s, otherwise it’s malformed. -->
    <xsl:if test="line|nest">

      <ul class='nesting' style="{$style}">
        <xsl:for-each select='line|nest'>

          <!-- Is this the last line?  If so, mark it as such so that it
               can be rendered differently. -->
          <xsl:variable name="class"><xsl:choose><xsl:when test="position() != last()">line</xsl:when><xsl:otherwise>lastline</xsl:otherwise></xsl:choose></xsl:variable>

          <li class='{$class}'>
            <span class='lineconn' />
            <span class='linebody'>
              <xsl:apply-templates select='.'/>
            </span>
          </li>
        </xsl:for-each>
      </ul>
    </xsl:if>

  </xsl:template>


  <xsl:template match="head|line">
    <code>
      <xsl:if test="@error">
        <xsl:attribute name="class">errorLine</xsl:attribute>
      </xsl:if>
      <xsl:if test="@warning">
        <xsl:attribute name="class">warningLine</xsl:attribute>
      </xsl:if>
      <xsl:if test="@priority = 3">
        <xsl:attribute name="class">prio3</xsl:attribute>
      </xsl:if>

      <xsl:if test="@type = 'serial'">
        <xsl:attribute name="class">serial</xsl:attribute>
      </xsl:if>

      <xsl:if test="@machine">
        <xsl:choose>
          <xsl:when test="@type = 'serial'">
            <span class="machine"><xsl:value-of select="@machine"/># </span>
          </xsl:when>
          <xsl:otherwise>
            <span class="machine"><xsl:value-of select="@machine"/>: </span>
          </xsl:otherwise>
        </xsl:choose>
      </xsl:if>

      <xsl:choose>
        <xsl:when test="@image">
          <a href="{@image}"><xsl:apply-templates/></a>
        </xsl:when>
        <xsl:otherwise>
          <xsl:apply-templates/>
        </xsl:otherwise>
      </xsl:choose>
    </code>
  </xsl:template>


  <xsl:template match="storeref">
    <em class='storeref'>
      <span class='popup'><xsl:apply-templates/></span>
      <span class='elided'>/...</span><xsl:apply-templates select='name'/><xsl:apply-templates select='path'/>
    </em>
  </xsl:template>

</xsl:stylesheet>
