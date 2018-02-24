<?xml version="1.0"?>
<!--
 ! tal.xsl - implements the XTAL attribute language
 !
 ! Joan Ordinas <jordinas@gmail.com>
 !-->
<!DOCTYPE xsl:transform [
<!ENTITY PUBID "-//W3C//DTD XHTML 1.0 Strict//EN">
<!ENTITY URLID "http://www.w3.org/TR/xhtml1/DTD/xhtml1-strict.dtd">
]>

<xsl:transform version="1.0"
  xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
  xmlns:tal="http://xml.zope.org/namespaces/tal"
  xmlns:metal="http://xml.zope.org/namespaces/metal"
  xmlns:xtal="urn:uuid:191a0b32-c67e-11df-8dcc-d8d3850d64e8"
  xmlns:p="urn:uuid:ebc0f478-c1bb-11df-93d5-d8d3850d64e8"
  xmlns:__x="__X"
  exclude-result-prefixes="p"
  xmlns:exslt="http://exslt.org/common"
  extension-element-prefixes="exslt"
>

<xsl:import href="metal.xsl"/>
<xsl:import href="tal.xsl"/>

<xsl:namespace-alias stylesheet-prefix="__x" result-prefix="xsl"/>

<xsl:output
  indent="yes"
  encoding="utf-8"
  method="xml"
  omit-xml-declaration="no"
/>

<xsl:template match="/">
  <xsl:variable name="tal">
    <xsl:apply-templates mode="metal"/>
  </xsl:variable>

  <xsl:for-each select="exslt:node-set($tal)">
    <xsl:call-template name="tal"/>
  </xsl:for-each>
</xsl:template>

<xsl:template name="tal">
  <__x:transform version="1.0"
    xmlns:exslt="http://exslt.org/common"
    xmlns:func="http://exslt.org/functions"
    extension-element-prefixes="exslt func"
    xmlns:atom="http://www.w3.org/2005/Atom"
    xmlns:dc="http://purl.org/dc/elements/1.1/"
    xmlns:html="http://www.w3.org/1999/xhtml"
    exclude-result-prefixes="atom html dc tal metal xtal"
  >
    <__x:variable name="nothing" select="/.."/>
    <__x:variable name="default" select="document('')/*"/>

    <func:function name="xtal:nothing">
      <__x:param name="object"/>
      <__x:choose>
        <__x:when test="exslt:object-type($object) = 'node-set'">
          <func:result select="count($object) = 0"/>
        </__x:when>
        <__x:otherwise>
          <func:result select="false()"/>
        </__x:otherwise>
      </__x:choose>
    </func:function>

    <func:function name="xtal:default">
      <__x:param name="object"/>
      <__x:choose>
        <__x:when test="exslt:object-type($object) = 'node-set'">
          <func:result select="generate-id($object) = generate-id($default)"/>
        </__x:when>
        <__x:otherwise>
          <func:result select="false()"/>
        </__x:otherwise>
      </__x:choose>
    </func:function>

    <xsl:choose>
      <xsl:when test="local-name(*) = 'html'">
        <__x:output
            method="xml"
            omit-xml-declaration="yes"
            encoding="utf-8"
            indent="yes"
            doctype-public="&PUBID;"
            doctype-system="&URLID;"
        />
      </xsl:when>
      <xsl:otherwise>
        <__x:output indent="yes" encoding="utf-8" method="xml"/>
      </xsl:otherwise>
    </xsl:choose>

    <__x:template match="/">
      <xsl:apply-templates mode="tal"/>
    </__x:template>

    <__x:template match="*">
      <__x:copy>
        <__x:apply-templates select="@*"/>

        <__x:apply-templates/>
      </__x:copy>
    </__x:template>

    <__x:template match="@*">
      <__x:copy select="."/>
    </__x:template>
  </__x:transform>
</xsl:template>

</xsl:transform>
<!--
vim:ts=2:sw=2:ai:nowrap:et
-->
