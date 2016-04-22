<?xml version="1.0"?>
<!--
 ! metal.xsl - implements METAL statements for XTAL attribute language
 !
 ! Joan Ordinas <jordinas@gmail.com>
 !-->

<!DOCTYPE xsl:transform [
<!ENTITY MSG1	"metal.xsl: missing @metal:fill-slot">
<!ENTITY MSG2	"metal.xsl: missing @metal:define-macro">
]>

<xsl:transform version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:metal="http://xml.zope.org/namespaces/metal"
	exclude-result-prefixes="metal"
>

<xsl:template match="/">
	<xsl:apply-templates mode="metal"/>
</xsl:template>

<xsl:template mode="metal" match="*[@metal:define-macro]"/>

<xsl:template mode="metal" match="@metal:define-macro | @metal:fill-slot"/>

<xsl:template mode="metal" match="*[@metal:use-macro]">
	<xsl:choose>
		<xsl:when test="contains(@metal:use-macro, '#')">
			<xsl:variable name="file"
				select="substring-before(@metal:use-macro, '#')"/>
			<xsl:variable name="macro-name"
				select="substring-after(@metal:use-macro, '#')"/>
			<xsl:variable name="macro"
				select="document($file, /)//*[@metal:define-macro = $macro-name]"/>

			<xsl:call-template name="expand">
				<xsl:with-param name="macro" select="$macro"/>
			</xsl:call-template>
		</xsl:when>	
		<xsl:otherwise>
			<xsl:variable name="macro-name" select="@metal:use-macro"/>
			<xsl:variable name="macro"
				select="//*[@metal:define-macro = $macro-name]"/>

			<xsl:call-template name="expand">
				<xsl:with-param name="macro" select="$macro"/>
			</xsl:call-template>
		</xsl:otherwise>	
	</xsl:choose>
</xsl:template>

<xsl:template name="expand">
	<xsl:param name="macro"/>

	<xsl:if test="not($macro)">
		<xsl:message terminate="yes">&MSG2;</xsl:message>
	</xsl:if>

	<xsl:variable name="context" select="."/>

	<xsl:for-each select="$macro">
		<xsl:copy>
			<xsl:apply-templates mode="metal" select="@*"/>

			<xsl:apply-templates mode="metal">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:for-each>
</xsl:template>

<xsl:template mode="metal" match="*[@metal:define-slot]">
	<xsl:param name="context"/>

	<xsl:variable name="slot-name" select="@metal:define-slot"/>
	<xsl:variable name="slot"
		select="$context//*[@metal:fill-slot = $slot-name]"/>

	<xsl:if test="not($slot)">
		<xsl:message terminate="yes">&MSG1;</xsl:message>
	</xsl:if>

	<xsl:for-each select="$slot">
		<xsl:copy>
			<xsl:apply-templates mode="metal" select="@*"/>

			<xsl:apply-templates mode="metal">
				<xsl:with-param name="context" select="$context"/>
			</xsl:apply-templates>
		</xsl:copy>
	</xsl:for-each>
</xsl:template>

<xsl:template mode="metal" match="*">
	<xsl:param name="context"/>

	<xsl:copy>
		<xsl:apply-templates select="@*" mode="metal"/>

		<xsl:apply-templates mode="metal">
			<xsl:with-param name="context" select="$context"/>
		</xsl:apply-templates>
	</xsl:copy>
</xsl:template>

<xsl:template mode="metal" match="@* | processing-instruction()">
		<xsl:copy/>
</xsl:template>

</xsl:transform>
<!--
vim:ts=2:sw=2:ai:nowrap
-->
