<?xml version="1.0" encoding="UTF-8" standalone="no"?>
<xsl:stylesheet xmlns:svrl="http://purl.oclc.org/dsdl/svrl" xmlns:iso="http://purl.oclc.org/dsdl/schematron" xmlns:saxon="http://saxon.sf.net/" xmlns:schold="http://www.ascc.net/xml/schematron" xmlns:tei="http://www.tei-c.org/ns/1.0" xmlns:xhtml="http://www.w3.org/1999/xhtml" xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:xsd="http://www.w3.org/2001/XMLSchema" xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="2.0">
<!--Implementers: please note that overriding process-prolog or process-root is 
    the preferred method for meta-stylesheets to use where possible. -->

<xsl:param name="archiveDirParameter" />
  <xsl:param name="archiveNameParameter" />
  <xsl:param name="fileNameParameter" />
  <xsl:param name="fileDirParameter" />
  <xsl:variable name="document-uri">
    <xsl:value-of select="document-uri(/)" />
  </xsl:variable>

<!--PHASES-->


<!--PROLOG-->
<xsl:output indent="yes" method="xml" omit-xml-declaration="no" standalone="yes" />

<!--XSD TYPES FOR XSLT2-->


<!--KEYS AND FUNCTIONS-->


<!--DEFAULT RULES-->


<!--MODE: SCHEMATRON-SELECT-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-select-full-path">
    <xsl:apply-templates mode="schematron-get-full-path" select="." />
  </xsl:template>

<!--MODE: SCHEMATRON-FULL-PATH-->
<!--This mode can be used to generate an ugly though full XPath for locators-->
<xsl:template match="*" mode="schematron-get-full-path">
    <xsl:apply-templates mode="schematron-get-full-path" select="parent::*" />
    <xsl:text>/</xsl:text>
    <xsl:choose>
      <xsl:when test="namespace-uri()=''">
        <xsl:value-of select="name()" />
      </xsl:when>
      <xsl:otherwise>
        <xsl:text>*:</xsl:text>
        <xsl:value-of select="local-name()" />
        <xsl:text>[namespace-uri()='</xsl:text>
        <xsl:value-of select="namespace-uri()" />
        <xsl:text>']</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:variable name="preceding" select="count(preceding-sibling::*[local-name()=local-name(current())                                   and namespace-uri() = namespace-uri(current())])" />
    <xsl:text>[</xsl:text>
    <xsl:value-of select="1+ $preceding" />
    <xsl:text>]</xsl:text>
  </xsl:template>
  <xsl:template match="@*" mode="schematron-get-full-path">
    <xsl:apply-templates mode="schematron-get-full-path" select="parent::*" />
    <xsl:text>/</xsl:text>
    <xsl:choose>
      <xsl:when test="namespace-uri()=''">@<xsl:value-of select="name()" />
</xsl:when>
      <xsl:otherwise>
        <xsl:text>@*[local-name()='</xsl:text>
        <xsl:value-of select="local-name()" />
        <xsl:text>' and namespace-uri()='</xsl:text>
        <xsl:value-of select="namespace-uri()" />
        <xsl:text>']</xsl:text>
      </xsl:otherwise>
    </xsl:choose>
  </xsl:template>

<!--MODE: SCHEMATRON-FULL-PATH-2-->
<!--This mode can be used to generate prefixed XPath for humans-->
<xsl:template match="node() | @*" mode="schematron-get-full-path-2">
    <xsl:for-each select="ancestor-or-self::*">
      <xsl:text>/</xsl:text>
      <xsl:value-of select="name(.)" />
      <xsl:if test="preceding-sibling::*[name(.)=name(current())]">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1" />
        <xsl:text>]</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test="not(self::*)">
      <xsl:text />/@<xsl:value-of select="name(.)" />
    </xsl:if>
  </xsl:template>
<!--MODE: SCHEMATRON-FULL-PATH-3-->
<!--This mode can be used to generate prefixed XPath for humans 
	(Top-level element has index)-->

<xsl:template match="node() | @*" mode="schematron-get-full-path-3">
    <xsl:for-each select="ancestor-or-self::*">
      <xsl:text>/</xsl:text>
      <xsl:value-of select="name(.)" />
      <xsl:if test="parent::*">
        <xsl:text>[</xsl:text>
        <xsl:value-of select="count(preceding-sibling::*[name(.)=name(current())])+1" />
        <xsl:text>]</xsl:text>
      </xsl:if>
    </xsl:for-each>
    <xsl:if test="not(self::*)">
      <xsl:text />/@<xsl:value-of select="name(.)" />
    </xsl:if>
  </xsl:template>

<!--MODE: GENERATE-ID-FROM-PATH -->
<xsl:template match="/" mode="generate-id-from-path" />
  <xsl:template match="text()" mode="generate-id-from-path">
    <xsl:apply-templates mode="generate-id-from-path" select="parent::*" />
    <xsl:value-of select="concat('.text-', 1+count(preceding-sibling::text()), '-')" />
  </xsl:template>
  <xsl:template match="comment()" mode="generate-id-from-path">
    <xsl:apply-templates mode="generate-id-from-path" select="parent::*" />
    <xsl:value-of select="concat('.comment-', 1+count(preceding-sibling::comment()), '-')" />
  </xsl:template>
  <xsl:template match="processing-instruction()" mode="generate-id-from-path">
    <xsl:apply-templates mode="generate-id-from-path" select="parent::*" />
    <xsl:value-of select="concat('.processing-instruction-', 1+count(preceding-sibling::processing-instruction()), '-')" />
  </xsl:template>
  <xsl:template match="@*" mode="generate-id-from-path">
    <xsl:apply-templates mode="generate-id-from-path" select="parent::*" />
    <xsl:value-of select="concat('.@', name())" />
  </xsl:template>
  <xsl:template match="*" mode="generate-id-from-path" priority="-0.5">
    <xsl:apply-templates mode="generate-id-from-path" select="parent::*" />
    <xsl:text>.</xsl:text>
    <xsl:value-of select="concat('.',name(),'-',1+count(preceding-sibling::*[name()=name(current())]),'-')" />
  </xsl:template>

<!--MODE: GENERATE-ID-2 -->
<xsl:template match="/" mode="generate-id-2">U</xsl:template>
  <xsl:template match="*" mode="generate-id-2" priority="2">
    <xsl:text>U</xsl:text>
    <xsl:number count="*" level="multiple" />
  </xsl:template>
  <xsl:template match="node()" mode="generate-id-2">
    <xsl:text>U.</xsl:text>
    <xsl:number count="*" level="multiple" />
    <xsl:text>n</xsl:text>
    <xsl:number count="node()" />
  </xsl:template>
  <xsl:template match="@*" mode="generate-id-2">
    <xsl:text>U.</xsl:text>
    <xsl:number count="*" level="multiple" />
    <xsl:text>_</xsl:text>
    <xsl:value-of select="string-length(local-name(.))" />
    <xsl:text>_</xsl:text>
    <xsl:value-of select="translate(name(),':','.')" />
  </xsl:template>
<!--Strip characters-->  <xsl:template match="text()" priority="-1" />

<!--SCHEMA SETUP-->
<xsl:template match="/">
    <svrl:schematron-output schemaVersion="" title="Schematron extension of the DTA ›Base Format‹ (DTABf)">
      <xsl:comment>
        <xsl:value-of select="$archiveDirParameter" />   
		 <xsl:value-of select="$archiveNameParameter" />  
		 <xsl:value-of select="$fileNameParameter" />  
		 <xsl:value-of select="$fileDirParameter" />
      </xsl:comment>
      <svrl:ns-prefix-in-attribute-values prefix="tei" uri="http://www.tei-c.org/ns/1.0" />
      <svrl:ns-prefix-in-attribute-values prefix="xs" uri="http://www.w3.org/2001/XMLSchema" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">pipeCharacter</xsl:attribute>
        <xsl:attribute name="name">pipeCharacter</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M3" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">allElements</xsl:attribute>
        <xsl:attribute name="name">allElements</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M4" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">allTextNodes</xsl:attribute>
        <xsl:attribute name="name">allTextNodes</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M5" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">biblElement</xsl:attribute>
        <xsl:attribute name="name">biblElement</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M6" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">capitalLetterI</xsl:attribute>
        <xsl:attribute name="name">capitalLetterI</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M7" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">choiceElement</xsl:attribute>
        <xsl:attribute name="name">choiceElement</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M8" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">choiceSubelements</xsl:attribute>
        <xsl:attribute name="name">choiceSubelements</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M9" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">corrElement</xsl:attribute>
        <xsl:attribute name="name">corrElement</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M10" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">correspAttribute</xsl:attribute>
        <xsl:attribute name="name">correspAttribute</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M11" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">divTypeAdvertisement</xsl:attribute>
        <xsl:attribute name="name">divTypeAdvertisement</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M12" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">expanElement</xsl:attribute>
        <xsl:attribute name="name">expanElement</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M13" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">facsInsideFirstPagebreak</xsl:attribute>
        <xsl:attribute name="name">facsInsideFirstPagebreak</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M14" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">facsInsidePagebreaks</xsl:attribute>
        <xsl:attribute name="name">facsInsidePagebreaks</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M15" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">facsOutsidePagebreaks</xsl:attribute>
        <xsl:attribute name="name">facsOutsidePagebreaks</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M16" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">fwHeader</xsl:attribute>
        <xsl:attribute name="name">fwHeader</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M17" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">hiRendRendition</xsl:attribute>
        <xsl:attribute name="name">hiRendRendition</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M18" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">kValueInRenditionAttribute</xsl:attribute>
        <xsl:attribute name="name">kValueInRenditionAttribute</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M19" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">metamark</xsl:attribute>
        <xsl:attribute name="name">metamark</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M20" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">nextAttribute</xsl:attribute>
        <xsl:attribute name="name">nextAttribute</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M21" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">noteElement</xsl:attribute>
        <xsl:attribute name="name">noteElement</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M22" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">pbElement</xsl:attribute>
        <xsl:attribute name="name">pbElement</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M23" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">prevAttribute</xsl:attribute>
        <xsl:attribute name="name">prevAttribute</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M24" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">regElement</xsl:attribute>
        <xsl:attribute name="name">regElement</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M25" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">respElement</xsl:attribute>
        <xsl:attribute name="name">respElement</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M26" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">salute</xsl:attribute>
        <xsl:attribute name="name">salute</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M27" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">sameAsAttribute</xsl:attribute>
        <xsl:attribute name="name">sameAsAttribute</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M28" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">sicElement</xsl:attribute>
        <xsl:attribute name="name">sicElement</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M29" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">signed</xsl:attribute>
        <xsl:attribute name="name">signed</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M30" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">subst</xsl:attribute>
        <xsl:attribute name="name">subst</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M31" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">targetAttribute</xsl:attribute>
        <xsl:attribute name="name">targetAttribute</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M32" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">teiHeaderElements</xsl:attribute>
        <xsl:attribute name="name">teiHeaderElements</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M33" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">tironianSignEtInText</xsl:attribute>
        <xsl:attribute name="name">tironianSignEtInText</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M34" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">underbar</xsl:attribute>
        <xsl:attribute name="name">underbar</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M35" select="/" />
      <svrl:active-pattern>
        <xsl:attribute name="document">
          <xsl:value-of select="document-uri(/)" />
        </xsl:attribute>
        <xsl:attribute name="id">values</xsl:attribute>
        <xsl:attribute name="name">values</xsl:attribute>
        <xsl:apply-templates />
      </svrl:active-pattern>
      <xsl:apply-templates mode="M36" select="/" />
    </svrl:schematron-output>
  </xsl:template>

<!--SCHEMATRON PATTERNS-->
<svrl:text>Schematron extension of the DTA ›Base Format‹ (DTABf)</svrl:text>

<!--PATTERN pipeCharacter-->


	<!--RULE -->
<xsl:template match="tei:*" mode="M3" priority="1000">
    <svrl:fired-rule context="tei:*" />

		<!--REPORT WARNING-->
<xsl:if test="text()[contains(., '|')]">
      <svrl:successful-report test="text()[contains(., '|')]">
        <xsl:attribute name="role">WARNING</xsl:attribute>
        <xsl:attribute name="location">
          <xsl:apply-templates mode="schematron-select-full-path" select="." />
        </xsl:attribute>
        <svrl:text>
                [W0007] The uncommon character '|' has been used within the text area.
            </svrl:text>
      </svrl:successful-report>
    </xsl:if>
    <xsl:apply-templates mode="M3" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M3" priority="-1" />
  <xsl:template match="@*|node()" mode="M3" priority="-2">
    <xsl:apply-templates mode="M3" select="@*|*" />
  </xsl:template>

<!--PATTERN allElements-->


	<!--RULE -->
<xsl:template match="tei:*[not(self::tei:hi)]" mode="M4" priority="1000">
    <svrl:fired-rule context="tei:*[not(self::tei:hi)]" />

		<!--REPORT WARNING-->
<xsl:if test="@rendition and @rend">
      <svrl:successful-report test="@rendition and @rend">
        <xsl:attribute name="role">WARNING</xsl:attribute>
        <xsl:attribute name="location">
          <xsl:apply-templates mode="schematron-select-full-path" select="." />
        </xsl:attribute>
        <svrl:text>
                [W0001] The usage of @rend or @rendition should be exclusionary.
            </svrl:text>
      </svrl:successful-report>
    </xsl:if>
    <xsl:apply-templates mode="M4" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M4" priority="-1" />
  <xsl:template match="@*|node()" mode="M4" priority="-2">
    <xsl:apply-templates mode="M4" select="@*|*" />
  </xsl:template>

<!--PATTERN allTextNodes-->


	<!--RULE -->
<xsl:template match="text()[contains(., '@')]" mode="M5" priority="1000">
    <svrl:fired-rule context="text()[contains(., '@')]" />

		<!--REPORT WARNING-->
<xsl:if test="ancestor::tei:text">
      <svrl:successful-report test="ancestor::tei:text">
        <xsl:attribute name="role">WARNING</xsl:attribute>
        <xsl:attribute name="location">
          <xsl:apply-templates mode="schematron-select-full-path" select="." />
        </xsl:attribute>
        <svrl:text>
                [W0002] The uncommon character '@' has been used within the text area.
            </svrl:text>
      </svrl:successful-report>
    </xsl:if>
    <xsl:apply-templates mode="M5" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M5" priority="-1" />
  <xsl:template match="@*|node()" mode="M5" priority="-2">
    <xsl:apply-templates mode="M5" select="@*|*" />
  </xsl:template>

<!--PATTERN biblElement-->


	<!--RULE -->
<xsl:template match="tei:bibl" mode="M6" priority="1000">
    <svrl:fired-rule context="tei:bibl" />

		<!--REPORT ERROR-->
<xsl:if test="parent::tei:quote">
      <svrl:successful-report test="parent::tei:quote">
        <xsl:attribute name="role">ERROR</xsl:attribute>
        <xsl:attribute name="location">
          <xsl:apply-templates mode="schematron-select-full-path" select="." />
        </xsl:attribute>
        <svrl:text>
                [E0003] Element "<xsl:text />
          <xsl:value-of select="name(.)" />
          <xsl:text />" not allowed within element "quote".
            </svrl:text>
      </svrl:successful-report>
    </xsl:if>

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="child::* or child::text()[normalize-space(.)]" />
      <xsl:otherwise>
        <svrl:failed-assert test="child::* or child::text()[normalize-space(.)]">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0004] Element "<xsl:text />
            <xsl:value-of select="name(.)" />
            <xsl:text />" may not be empty.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--REPORT -->
<xsl:if test=".[@type][ancestor::tei:text]">
      <svrl:successful-report test=".[@type][ancestor::tei:text]">
        <xsl:attribute name="location">
          <xsl:apply-templates mode="schematron-select-full-path" select="." />
        </xsl:attribute>
        <svrl:text>
                [E0033] Attribute @type in element "<xsl:text />
          <xsl:value-of select="name(.)" />
          <xsl:text />" not allowed within the //text area. 
            </svrl:text>
      </svrl:successful-report>
    </xsl:if>
    <xsl:apply-templates mode="M6" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M6" priority="-1" />
  <xsl:template match="@*|node()" mode="M6" priority="-2">
    <xsl:apply-templates mode="M6" select="@*|*" />
  </xsl:template>

<!--PATTERN capitalLetterI-->
<xsl:variable name="x" select="(//tei:*[contains(@rendition,'#aq')] or //tei:*[contains(@rendition, '#fr')]) and //tei:text//text()[not(ancestor::tei:*[contains(@rendition,'#aq')])][not(ancestor::tei:note[@type='editorial'])][contains(., 'I')]" />

	<!--RULE -->
<xsl:template match="//tei:TEI" mode="M7" priority="1000">
    <svrl:fired-rule context="//tei:TEI" />

		<!--REPORT WARNING-->
<xsl:if test="$x">
      <svrl:successful-report test="$x">
        <xsl:attribute name="role">WARNING</xsl:attribute>
        <xsl:attribute name="location">
          <xsl:apply-templates mode="schematron-select-full-path" select="." />
        </xsl:attribute>
        <svrl:text>
                [W0004] The document contains capital letter I within Fraktur text. Should be capital letter J? 
                Search for XPath //text//text()[not(ancestor::*[contains(@rendition,'#aq')])][contains(., 'I')] 
                to find all text nodes with incorrect instances of capital 'I' within the document. 
            </svrl:text>
      </svrl:successful-report>
    </xsl:if>
    <xsl:apply-templates mode="M7" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M7" priority="-1" />
  <xsl:template match="@*|node()" mode="M7" priority="-2">
    <xsl:apply-templates mode="M7" select="@*|*" />
  </xsl:template>

<!--PATTERN choiceElement-->


	<!--RULE -->
<xsl:template match="tei:choice" mode="M8" priority="1000">
    <svrl:fired-rule context="tei:choice" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="count(*) > 1" />
      <xsl:otherwise>
        <svrl:failed-assert test="count(*) > 1">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0005] Element "<xsl:text />
            <xsl:value-of select="name(.)" />
            <xsl:text />" must have at least two child elements.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M8" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M8" priority="-1" />
  <xsl:template match="@*|node()" mode="M8" priority="-2">
    <xsl:apply-templates mode="M8" select="@*|*" />
  </xsl:template>

<!--PATTERN choiceSubelements-->


	<!--RULE -->
<xsl:template match="tei:corr | tei:expan | tei:reg | tei:sic" mode="M9" priority="1000">
    <svrl:fired-rule context="tei:corr | tei:expan | tei:reg | tei:sic" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="parent::tei:choice" />
      <xsl:otherwise>
        <svrl:failed-assert test="parent::tei:choice">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0013] Element "<xsl:text />
            <xsl:value-of select="name(.)" />
            <xsl:text />" must have a parent element "choice".
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M9" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M9" priority="-1" />
  <xsl:template match="@*|node()" mode="M9" priority="-2">
    <xsl:apply-templates mode="M9" select="@*|*" />
  </xsl:template>

<!--PATTERN corrElement-->


	<!--RULE -->
<xsl:template match="tei:corr" mode="M10" priority="1000">
    <svrl:fired-rule context="tei:corr" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="count(preceding-sibling::tei:sic | following-sibling::tei:sic) = 1" />
      <xsl:otherwise>
        <svrl:failed-assert test="count(preceding-sibling::tei:sic | following-sibling::tei:sic) = 1">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0006] Element "<xsl:text />
            <xsl:value-of select="name(.)" />
            <xsl:text />" must have exactly one corresponding "sic" element.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M10" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M10" priority="-1" />
  <xsl:template match="@*|node()" mode="M10" priority="-2">
    <xsl:apply-templates mode="M10" select="@*|*" />
  </xsl:template>

<!--PATTERN correspAttribute-->


	<!--RULE -->
<xsl:template match="tei:*[@corresp]" mode="M11" priority="1000">
    <svrl:fired-rule context="tei:*[@corresp]" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="matches(@corresp, '^#|^https?://')" />
      <xsl:otherwise>
        <svrl:failed-assert test="matches(@corresp, '^#|^https?://')">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0028] The value of attribute @corresp must be a URL or same document reference 
                starting with 'http://' or 'https://' or '#'.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT error-->
<xsl:choose>
      <xsl:when test="if (starts-with(@corresp, '#')) then //@xml:id = substring-after(@corresp, '#') else 1" />
      <xsl:otherwise>
        <svrl:failed-assert test="if (starts-with(@corresp, '#')) then //@xml:id = substring-after(@corresp, '#') else 1">
          <xsl:attribute name="role">error</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0026] The value of attribute @corresp must have a corresponding @xml:id-value within the same document.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M11" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M11" priority="-1" />
  <xsl:template match="@*|node()" mode="M11" priority="-2">
    <xsl:apply-templates mode="M11" select="@*|*" />
  </xsl:template>

<!--PATTERN divTypeAdvertisement-->


	<!--RULE -->
<xsl:template match="tei:div[@type='advertisement']" mode="M12" priority="1000">
    <svrl:fired-rule context="tei:div[@type='advertisement']" />

		<!--REPORT ERROR-->
<xsl:if test="preceding::tei:div[@type[matches(., '^j[A-Z]')]] | following::tei:div[@type[matches(., 'j[A-Z]')]] |                  ancestor::tei:div[@type[matches(., 'j[A-Z]')]] | descendant::tei:div[@type[matches(., 'j[A-Z]')]]">
      <svrl:successful-report test="preceding::tei:div[@type[matches(., '^j[A-Z]')]] | following::tei:div[@type[matches(., 'j[A-Z]')]] | ancestor::tei:div[@type[matches(., 'j[A-Z]')]] | descendant::tei:div[@type[matches(., 'j[A-Z]')]]">
        <xsl:attribute name="role">ERROR</xsl:attribute>
        <xsl:attribute name="location">
          <xsl:apply-templates mode="schematron-select-full-path" select="." />
        </xsl:attribute>
        <svrl:text>
                [E0027] Value @type="advertisement" in element "div" not allowed within newspapers or journals; 
                expected values are "jAnnouncements" or "jAn".
            </svrl:text>
      </svrl:successful-report>
    </xsl:if>
    <xsl:apply-templates mode="M12" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M12" priority="-1" />
  <xsl:template match="@*|node()" mode="M12" priority="-2">
    <xsl:apply-templates mode="M12" select="@*|*" />
  </xsl:template>

<!--PATTERN expanElement-->


	<!--RULE -->
<xsl:template match="tei:expan" mode="M13" priority="1000">
    <svrl:fired-rule context="tei:expan" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="count(preceding-sibling::tei:abbr | following-sibling::tei:abbr) = 1" />
      <xsl:otherwise>
        <svrl:failed-assert test="count(preceding-sibling::tei:abbr | following-sibling::tei:abbr) = 1">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0007] Element "<xsl:text />
            <xsl:value-of select="name(.)" />
            <xsl:text />" must have exactly one corresponding "abbr" element.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M13" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M13" priority="-1" />
  <xsl:template match="@*|node()" mode="M13" priority="-2">
    <xsl:apply-templates mode="M13" select="@*|*" />
  </xsl:template>

<!--PATTERN facsInsideFirstPagebreak-->


	<!--RULE -->
<xsl:template match="tei:pb[1][not(preceding::tei:pb)]" mode="M14" priority="1000">
    <svrl:fired-rule context="tei:pb[1][not(preceding::tei:pb)]" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="@facs[matches(., '^#f0001$')]" />
      <xsl:otherwise>
        <svrl:failed-assert test="@facs[matches(., '^#f0001$')]">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0015] Value of @facs within first "pb" incorrect; expected value: #f0001. 
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M14" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M14" priority="-1" />
  <xsl:template match="@*|node()" mode="M14" priority="-2">
    <xsl:apply-templates mode="M14" select="@*|*" />
  </xsl:template>

<!--PATTERN facsInsidePagebreaks-->


	<!--RULE -->
<xsl:template match="tei:pb[@facs]" mode="M15" priority="1000">
    <svrl:fired-rule context="tei:pb[@facs]" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="if (matches(@facs, '^#f\d\d\d\d') and matches(preceding::tei:pb[1]/@facs, '^#f\d\d\d\d') and (preceding::tei:pb)) then xs:integer(substring(@facs, 3)) = preceding::tei:pb[1]/xs:integer(substring(@facs, 3)) +1 else 1" />
      <xsl:otherwise>
        <svrl:failed-assert test="if (matches(@facs, '^#f\d\d\d\d') and matches(preceding::tei:pb[1]/@facs, '^#f\d\d\d\d') and (preceding::tei:pb)) then xs:integer(substring(@facs, 3)) = preceding::tei:pb[1]/xs:integer(substring(@facs, 3)) +1 else 1">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0014] Value of @facs within "pb" incorrect; @facs-values of "pb"-elements have 
                to increase by 1 continually starting with #f0001.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M15" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M15" priority="-1" />
  <xsl:template match="@*|node()" mode="M15" priority="-2">
    <xsl:apply-templates mode="M15" select="@*|*" />
  </xsl:template>

<!--PATTERN facsOutsidePagebreaks-->


	<!--RULE -->
<xsl:template match="tei:*[@facs][not(self::tei:pb)]" mode="M16" priority="1000">
    <svrl:fired-rule context="tei:*[@facs][not(self::tei:pb)]" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="matches(@facs, '^#|^https?://')" />
      <xsl:otherwise>
        <svrl:failed-assert test="matches(@facs, '^#|^https?://')">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0016] The value of attribute @facs must be a URL or same document reference 
                starting with 'http://' or 'https://' or '#'.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M16" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M16" priority="-1" />
  <xsl:template match="@*|node()" mode="M16" priority="-2">
    <xsl:apply-templates mode="M16" select="@*|*" />
  </xsl:template>

<!--PATTERN fwHeader-->


	<!--RULE -->
<xsl:template match="tei:fw[@type='header']" mode="M17" priority="1000">
    <svrl:fired-rule context="tei:fw[@type='header']" />

		<!--REPORT ERROR-->
<xsl:if test="string(preceding::tei:pb[1]/@facs) = string(following::tei:fw[@type='header'][1]/preceding::tei:pb[1]/@facs)">
      <svrl:successful-report test="string(preceding::tei:pb[1]/@facs) = string(following::tei:fw[@type='header'][1]/preceding::tei:pb[1]/@facs)">
        <xsl:attribute name="role">ERROR</xsl:attribute>
        <xsl:attribute name="location">
          <xsl:apply-templates mode="schematron-select-full-path" select="." />
        </xsl:attribute>
        <svrl:text>
                [E0002] Each page may only contain one header.
            </svrl:text>
      </svrl:successful-report>
    </xsl:if>
    <xsl:apply-templates mode="M17" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M17" priority="-1" />
  <xsl:template match="@*|node()" mode="M17" priority="-2">
    <xsl:apply-templates mode="M17" select="@*|*" />
  </xsl:template>

<!--PATTERN hiRendRendition-->


	<!--RULE -->
<xsl:template match="tei:hi" mode="M18" priority="1000">
    <svrl:fired-rule context="tei:hi" />

		<!--REPORT WARNING-->
<xsl:if test="(@rendition and @rend) and @rendition!='#none'">
      <svrl:successful-report test="(@rendition and @rend) and @rendition!='#none'">
        <xsl:attribute name="role">WARNING</xsl:attribute>
        <xsl:attribute name="location">
          <xsl:apply-templates mode="schematron-select-full-path" select="." />
        </xsl:attribute>
        <svrl:text>
                [W0006] The attribute @rend in "<xsl:text />
          <xsl:value-of select="name(.)" />
          <xsl:text />" should be accompanied by an attribute-value-pair @rendition="#zero".
            </svrl:text>
      </svrl:successful-report>
    </xsl:if>
    <xsl:apply-templates mode="M18" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M18" priority="-1" />
  <xsl:template match="@*|node()" mode="M18" priority="-2">
    <xsl:apply-templates mode="M18" select="@*|*" />
  </xsl:template>

<!--PATTERN kValueInRenditionAttribute-->


	<!--RULE -->
<xsl:template match="tei:*[@rendition='#k']" mode="M19" priority="1000">
    <svrl:fired-rule context="tei:*[@rendition='#k']" />

		<!--REPORT ERROR-->
<xsl:if test="contains(self::tei:*, 'ſ')">
      <svrl:successful-report test="contains(self::tei:*, 'ſ')">
        <xsl:attribute name="role">ERROR</xsl:attribute>
        <xsl:attribute name="location">
          <xsl:apply-templates mode="schematron-select-full-path" select="." />
        </xsl:attribute>
        <svrl:text>
                [E0018] Long s not allowed within small capitals area.
            </svrl:text>
      </svrl:successful-report>
    </xsl:if>
    <xsl:apply-templates mode="M19" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M19" priority="-1" />
  <xsl:template match="@*|node()" mode="M19" priority="-2">
    <xsl:apply-templates mode="M19" select="@*|*" />
  </xsl:template>

<!--PATTERN metamark-->


	<!--RULE -->
<xsl:template match="tei:metamark[@function | @place]" mode="M20" priority="1000">
    <svrl:fired-rule context="tei:metamark[@function | @place]" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="@function and @place" />
      <xsl:otherwise>
        <svrl:failed-assert test="@function and @place">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0034] Element "<xsl:text />
            <xsl:value-of select="name(.)" />
            <xsl:text />" must contain both attributes @function and @place or neither.</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M20" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M20" priority="-1" />
  <xsl:template match="@*|node()" mode="M20" priority="-2">
    <xsl:apply-templates mode="M20" select="@*|*" />
  </xsl:template>

<!--PATTERN nextAttribute-->


	<!--RULE -->
<xsl:template match="tei:*[@next]" mode="M21" priority="1000">
    <svrl:fired-rule context="tei:*[@next]" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="starts-with(@next, '#')" />
      <xsl:otherwise>
        <svrl:failed-assert test="starts-with(@next, '#')">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0017] The value of attribute @next must be a same document reference starting with '#'.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT error-->
<xsl:choose>
      <xsl:when test="if (starts-with(@next, '#')) then //@xml:id = substring-after(@next, '#') else 1" />
      <xsl:otherwise>
        <svrl:failed-assert test="if (starts-with(@next, '#')) then //@xml:id = substring-after(@next, '#') else 1">
          <xsl:attribute name="role">error</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0019] The value of attribute @next must have a corresponding @xml:id-value within the same document.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M21" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M21" priority="-1" />
  <xsl:template match="@*|node()" mode="M21" priority="-2">
    <xsl:apply-templates mode="M21" select="@*|*" />
  </xsl:template>

<!--PATTERN noteElement-->


	<!--RULE -->
<xsl:template match="tei:note" mode="M22" priority="1000">
    <svrl:fired-rule context="tei:note" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="@type or @place" />
      <xsl:otherwise>
        <svrl:failed-assert test="@type or @place">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0035] Element "<xsl:text />
            <xsl:value-of select="name(.)" />
            <xsl:text />" must contain an attribute @place or @type.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--REPORT ERROR-->
<xsl:if test="preceding::bibl[@type!='MAN'] and @resp and not(@type='editorial')">
      <svrl:successful-report test="preceding::bibl[@type!='MAN'] and @resp and not(@type='editorial')">
        <xsl:attribute name="role">ERROR</xsl:attribute>
        <xsl:attribute name="location">
          <xsl:apply-templates mode="schematron-select-full-path" select="." />
        </xsl:attribute>
        <svrl:text>
                [E0036] Element "<xsl:text />
          <xsl:value-of select="name(.)" />
          <xsl:text />" must contain an attribute @place or @type.
            </svrl:text>
      </svrl:successful-report>
    </xsl:if>
    <xsl:apply-templates mode="M22" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M22" priority="-1" />
  <xsl:template match="@*|node()" mode="M22" priority="-2">
    <xsl:apply-templates mode="M22" select="@*|*" />
  </xsl:template>

<!--PATTERN pbElement-->


	<!--RULE -->
<xsl:template match="tei:pb" mode="M23" priority="1000">
    <svrl:fired-rule context="tei:pb" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="@facs[matches(., '#f[0-9]{4}')] and @facs[matches(., '^#f0*([1-9][0-9]*)$')]" />
      <xsl:otherwise>
        <svrl:failed-assert test="@facs[matches(., '#f[0-9]{4}')] and @facs[matches(., '^#f0*([1-9][0-9]*)$')]">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0008] Wrong format of @facs-value in element "<xsl:text />
            <xsl:value-of select="name(.)" />
            <xsl:text />"; should be "#f" followed by 4 digits (0-9) starting with 
                #f0001 and increasing by 1 continually. 
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M23" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M23" priority="-1" />
  <xsl:template match="@*|node()" mode="M23" priority="-2">
    <xsl:apply-templates mode="M23" select="@*|*" />
  </xsl:template>

<!--PATTERN prevAttribute-->


	<!--RULE -->
<xsl:template match="tei:*[@prev]" mode="M24" priority="1000">
    <svrl:fired-rule context="tei:*[@prev]" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="starts-with(@prev, '#')" />
      <xsl:otherwise>
        <svrl:failed-assert test="starts-with(@prev, '#')">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0025] The value of attribute @prev must be a same document reference starting with '#'.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT error-->
<xsl:choose>
      <xsl:when test="if (starts-with(@prev, '#')) then //@xml:id = substring-after(@prev, '#') else 1" />
      <xsl:otherwise>
        <svrl:failed-assert test="if (starts-with(@prev, '#')) then //@xml:id = substring-after(@prev, '#') else 1">
          <xsl:attribute name="role">error</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0021] The value of attribute @prev must have a corresponding @xml:id-value within the same document.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M24" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M24" priority="-1" />
  <xsl:template match="@*|node()" mode="M24" priority="-2">
    <xsl:apply-templates mode="M24" select="@*|*" />
  </xsl:template>

<!--PATTERN regElement-->


	<!--RULE -->
<xsl:template match="tei:reg" mode="M25" priority="1000">
    <svrl:fired-rule context="tei:reg" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="count(preceding-sibling::tei:orig | following-sibling::tei:orig) = 1" />
      <xsl:otherwise>
        <svrl:failed-assert test="count(preceding-sibling::tei:orig | following-sibling::tei:orig) = 1">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0009] Element "<xsl:text />
            <xsl:value-of select="name(.)" />
            <xsl:text />" must have exactly one corresponding "orig" element.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M25" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M25" priority="-1" />
  <xsl:template match="@*|node()" mode="M25" priority="-2">
    <xsl:apply-templates mode="M25" select="@*|*" />
  </xsl:template>

<!--PATTERN respElement-->


	<!--RULE -->
<xsl:template match="tei:resp" mode="M26" priority="1000">
    <svrl:fired-rule context="tei:resp" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="child::tei:*" />
      <xsl:otherwise>
        <svrl:failed-assert test="child::tei:*">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0010] Element "<xsl:text />
            <xsl:value-of select="name(.)" />
            <xsl:text />" must have at least one child element.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--REPORT ERROR-->
<xsl:if test="child::text()[normalize-space(.)]">
      <svrl:successful-report test="child::text()[normalize-space(.)]">
        <xsl:attribute name="role">ERROR</xsl:attribute>
        <xsl:attribute name="location">
          <xsl:apply-templates mode="schematron-select-full-path" select="." />
        </xsl:attribute>
        <svrl:text>
                [E0011] Text not allowed here; expected child element or closing tag.
            </svrl:text>
      </svrl:successful-report>
    </xsl:if>
    <xsl:apply-templates mode="M26" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M26" priority="-1" />
  <xsl:template match="@*|node()" mode="M26" priority="-2">
    <xsl:apply-templates mode="M26" select="@*|*" />
  </xsl:template>

<!--PATTERN salute-->


	<!--RULE -->
<xsl:template match="tei:salute" mode="M27" priority="1000">
    <svrl:fired-rule context="tei:salute" />

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="ancestor::tei:opener|ancestor::tei:closer" />
      <xsl:otherwise>
        <svrl:failed-assert test="ancestor::tei:opener|ancestor::tei:closer">
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0030] The element "salute" may only occur within the elements "opener" or "closer".
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M27" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M27" priority="-1" />
  <xsl:template match="@*|node()" mode="M27" priority="-2">
    <xsl:apply-templates mode="M27" select="@*|*" />
  </xsl:template>

<!--PATTERN sameAsAttribute-->


	<!--RULE -->
<xsl:template match="tei:*[@sameAs]" mode="M28" priority="1000">
    <svrl:fired-rule context="tei:*[@sameAs]" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="starts-with(@sameAs, '#')" />
      <xsl:otherwise>
        <svrl:failed-assert test="starts-with(@sameAs, '#')">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0022] The value of attribute @sameAs must be a same document reference starting with '#'.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT error-->
<xsl:choose>
      <xsl:when test="if (starts-with(@sameAs, '#')) then //@xml:id = substring-after(@sameAs, '#') else 1" />
      <xsl:otherwise>
        <svrl:failed-assert test="if (starts-with(@sameAs, '#')) then //@xml:id = substring-after(@sameAs, '#') else 1">
          <xsl:attribute name="role">error</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0023] The value of attribute @sameAs must have a corresponding @xml:id-value within the same document.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M28" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M28" priority="-1" />
  <xsl:template match="@*|node()" mode="M28" priority="-2">
    <xsl:apply-templates mode="M28" select="@*|*" />
  </xsl:template>

<!--PATTERN sicElement-->


	<!--RULE -->
<xsl:template match="tei:sic" mode="M29" priority="1000">
    <svrl:fired-rule context="tei:sic" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="count(preceding-sibling::tei:corr | following-sibling::tei:corr) = 1" />
      <xsl:otherwise>
        <svrl:failed-assert test="count(preceding-sibling::tei:corr | following-sibling::tei:corr) = 1">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0012] Element "<xsl:text />
            <xsl:value-of select="name(.)" />
            <xsl:text />" must have exactly one corresponding "corr" element.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M29" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M29" priority="-1" />
  <xsl:template match="@*|node()" mode="M29" priority="-2">
    <xsl:apply-templates mode="M29" select="@*|*" />
  </xsl:template>

<!--PATTERN signed-->


	<!--RULE -->
<xsl:template match="tei:signed" mode="M30" priority="1000">
    <svrl:fired-rule context="tei:signed" />

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="ancestor::tei:closer" />
      <xsl:otherwise>
        <svrl:failed-assert test="ancestor::tei:closer">
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0029] The element "signed" may only occur within the element "closer".
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M30" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M30" priority="-1" />
  <xsl:template match="@*|node()" mode="M30" priority="-2">
    <xsl:apply-templates mode="M30" select="@*|*" />
  </xsl:template>

<!--PATTERN subst-->


	<!--RULE -->
<xsl:template match="tei:subst" mode="M31" priority="1000">
    <svrl:fired-rule context="tei:subst" />

		<!--ASSERT -->
<xsl:choose>
      <xsl:when test="child::tei:add and child::tei:del" />
      <xsl:otherwise>
        <svrl:failed-assert test="child::tei:add and child::tei:del">
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
					[E0037] The element "subst" must contain both elements "add" and "del" as child elements.
				</svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M31" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M31" priority="-1" />
  <xsl:template match="@*|node()" mode="M31" priority="-2">
    <xsl:apply-templates mode="M31" select="@*|*" />
  </xsl:template>

<!--PATTERN targetAttribute-->


	<!--RULE -->
<xsl:template match="tei:*[@target]" mode="M32" priority="1000">
    <svrl:fired-rule context="tei:*[@target]" />

		<!--ASSERT ERROR-->
<xsl:choose>
      <xsl:when test="matches(@target, '^#|^https?://')" />
      <xsl:otherwise>
        <svrl:failed-assert test="matches(@target, '^#|^https?://')">
          <xsl:attribute name="role">ERROR</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0024] The value of attribute @target must be a URL or same document 
                reference starting with 'http://' or 'https://' or '#' or '#f'.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT error-->
<xsl:choose>
      <xsl:when test="if (starts-with(@target, '#') and not(starts-with(@target, '#f'))) then //@xml:id = substring-after(@target, '#') else 1" />
      <xsl:otherwise>
        <svrl:failed-assert test="if (starts-with(@target, '#') and not(starts-with(@target, '#f'))) then //@xml:id = substring-after(@target, '#') else 1">
          <xsl:attribute name="role">error</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0032] Value of attribute @target must have a corresponding @xml:id-value within the same document.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT error-->
<xsl:choose>
      <xsl:when test="if (starts-with(@target, '#f')) then //tei:pb/@facs = //./@target else 1" />
      <xsl:otherwise>
        <svrl:failed-assert test="if (starts-with(@target, '#f')) then //tei:pb/@facs = //./@target else 1">
          <xsl:attribute name="role">error</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0020] Value of attribute @target must have a corresponding @facs-value 
                within a &lt;pb&gt; element in the same document.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>

		<!--ASSERT error-->
<xsl:choose>
      <xsl:when test="if (. = tei:licence) then starts-with(@target, 'https?://') else 1" />
      <xsl:otherwise>
        <svrl:failed-assert test="if (. = tei:licence) then starts-with(@target, 'https?://') else 1">
          <xsl:attribute name="role">error</xsl:attribute>
          <xsl:attribute name="location">
            <xsl:apply-templates mode="schematron-select-full-path" select="." />
          </xsl:attribute>
          <svrl:text>
                [E0031] Value of attribute @target must have a corresponding @facs-value 
                within a pb-element in the same document.
            </svrl:text>
        </svrl:failed-assert>
      </xsl:otherwise>
    </xsl:choose>
    <xsl:apply-templates mode="M32" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M32" priority="-1" />
  <xsl:template match="@*|node()" mode="M32" priority="-2">
    <xsl:apply-templates mode="M32" select="@*|*" />
  </xsl:template>

<!--PATTERN teiHeaderElements-->


	<!--RULE -->
<xsl:template match="tei:addName | tei:address | tei:addrLine | tei:email | tei:biblFull | tei:country |              tei:forename | tei:genName | tei:measure | tei:msDesc | tei:nameLink | tei:publicationStmt |              tei:resp | tei:respStmt | tei:roleName | tei:surname | tei:titleStmt | tei:title" mode="M33" priority="1000">
    <svrl:fired-rule context="tei:addName | tei:address | tei:addrLine | tei:email | tei:biblFull | tei:country |              tei:forename | tei:genName | tei:measure | tei:msDesc | tei:nameLink | tei:publicationStmt |              tei:resp | tei:respStmt | tei:roleName | tei:surname | tei:titleStmt | tei:title" />

		<!--REPORT ERROR-->
<xsl:if test="ancestor::tei:text">
      <svrl:successful-report test="ancestor::tei:text">
        <xsl:attribute name="role">ERROR</xsl:attribute>
        <xsl:attribute name="location">
          <xsl:apply-templates mode="schematron-select-full-path" select="." />
        </xsl:attribute>
        <svrl:text>
                [E0001] Element "<xsl:text />
          <xsl:value-of select="name(.)" />
          <xsl:text />" not allowed anywhere within element "text".
            </svrl:text>
      </svrl:successful-report>
    </xsl:if>
    <xsl:apply-templates mode="M33" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M33" priority="-1" />
  <xsl:template match="@*|node()" mode="M33" priority="-2">
    <xsl:apply-templates mode="M33" select="@*|*" />
  </xsl:template>

<!--PATTERN tironianSignEtInText-->


	<!--RULE -->
<xsl:template match="text()[contains(., '⁊')]" mode="M34" priority="1000">
    <svrl:fired-rule context="text()[contains(., '⁊')]" />

		<!--REPORT WARNING-->
<xsl:if test="ancestor::tei:text">
      <svrl:successful-report test="ancestor::tei:text">
        <xsl:attribute name="role">WARNING</xsl:attribute>
        <xsl:attribute name="location">
          <xsl:apply-templates mode="schematron-select-full-path" select="." />
        </xsl:attribute>
        <svrl:text>
                [W0003] The Unicode character 'U+204A' (Tironian sign et) has been used; check, if the source character is 'U+A75B' (Latin small letter r rotunda) instead.
            </svrl:text>
      </svrl:successful-report>
    </xsl:if>
    <xsl:apply-templates mode="M34" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M34" priority="-1" />
  <xsl:template match="@*|node()" mode="M34" priority="-2">
    <xsl:apply-templates mode="M34" select="@*|*" />
  </xsl:template>

<!--PATTERN underbar-->


	<!--RULE -->
<xsl:template match="text()[contains(.,'_ _')]" mode="M35" priority="1000">
    <svrl:fired-rule context="text()[contains(.,'_ _')]" />

		<!--REPORT WARNING-->
<xsl:if test="ancestor::tei:text">
      <svrl:successful-report test="ancestor::tei:text">
        <xsl:attribute name="role">WARNING</xsl:attribute>
        <xsl:attribute name="location">
          <xsl:apply-templates mode="schematron-select-full-path" select="." />
        </xsl:attribute>
        <svrl:text>
                [W0008] The string "_ _" has been used; check, if this is an adequate transcription of the source.
            </svrl:text>
      </svrl:successful-report>
    </xsl:if>
    <xsl:apply-templates mode="M35" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M35" priority="-1" />
  <xsl:template match="@*|node()" mode="M35" priority="-2">
    <xsl:apply-templates mode="M35" select="@*|*" />
  </xsl:template>

<!--PATTERN values-->


	<!--RULE -->
<xsl:template match="tei:*" mode="M36" priority="1000">
    <svrl:fired-rule context="tei:*" />

		<!--REPORT WARNING-->
<xsl:if test="@*=''">
      <svrl:successful-report test="@*=''">
        <xsl:attribute name="role">WARNING</xsl:attribute>
        <xsl:attribute name="location">
          <xsl:apply-templates mode="schematron-select-full-path" select="." />
        </xsl:attribute>
        <svrl:text>
                [W0005] Attribute values may not be the empty string.
            </svrl:text>
      </svrl:successful-report>
    </xsl:if>
    <xsl:apply-templates mode="M36" select="@*|*" />
  </xsl:template>
  <xsl:template match="text()" mode="M36" priority="-1" />
  <xsl:template match="@*|node()" mode="M36" priority="-2">
    <xsl:apply-templates mode="M36" select="@*|*" />
  </xsl:template>
</xsl:stylesheet>
