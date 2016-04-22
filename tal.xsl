<?xml version="1.0"?>
<!--
 ! tal.xsl - implements TAL statements for XTAL attribute language
 !
 ! Joan Ordinas <jordinas@gmail.com>
 !-->

<!DOCTYPE xsl:transform [
<!ENTITY MSG1	"tal.xsl: tal:content and tal:replace clash">
<!ENTITY MSG2 "tal.xsl: TAL statement tal:on-error not implemented">
<!ENTITY MSG3	"tal.xsl: tal:content and tal:omit-tag clash">
<!ENTITY MSG4	"tal.xsl: tal:replace and tal:omit-tag clash">
]>

<xsl:transform version="1.0"
	xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:tal="http://xml.zope.org/namespaces/tal"
	xmlns:p="urn:uuid:c9a9e2ac-c67d-11df-a7a4-d8d3850d64e8"
	xmlns:__x="__X"
	exclude-result-prefixes="p"
>

<xsl:namespace-alias stylesheet-prefix="__x" result-prefix="xsl"/>

<!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 ! statements (elements)
 !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->

<xsl:template name="p:copy-element">
	<xsl:element name="{name(.)}" namespace="{namespace-uri(.)}">
		<xsl:copy-of select="namespace::*"/>

		<xsl:apply-templates mode="tal" select="@*"/>

		<xsl:apply-templates mode="tal"/>
	</xsl:element>
</xsl:template>

<xsl:template mode="tal" priority="80"
							match="*[@tal:content and @tal:replace]"
>
	<xsl:message terminate="yes">&MSG1;</xsl:message>
</xsl:template>

<xsl:template mode="tal" priority="80"
							match="*[@tal:replace and @tal:omit-tag]"
>
	<xsl:message terminate="yes">&MSG4;</xsl:message>
</xsl:template>

<!--
 ! tal:define
 !-->
<xsl:template mode="tal" priority="70"
							match="*[@tal:define]"
>
	<xsl:call-template name="p:defines">
		<xsl:with-param name="arg" select="normalize-space(@tal:define)"/>
	</xsl:call-template>

	<xsl:choose>
		<xsl:when test="@tal:condition">
			<xsl:call-template name="p:tal_condition"/>
		</xsl:when>
		<xsl:when test="@tal:repeat">
			<xsl:call-template name="p:tal_repeat"/>
		</xsl:when>
		<xsl:when test="@tal:content">
			<xsl:call-template name="p:tal_content"/>
		</xsl:when>
		<xsl:when test="@tal:replace">
			<xsl:call-template name="p:tal_replace"/>
		</xsl:when>
		<xsl:when test="@tal:omit-tag">
			<xsl:call-template name="p:tal_omit-tag"/>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="p:copy-element"/>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="p:defines">
	<xsl:param name="arg"/>

	<xsl:choose>
		<xsl:when test="contains($arg, '; ')">
			<xsl:call-template name="p:defines">
				<xsl:with-param name="arg" select="substring-after($arg, '; ')"/>
			</xsl:call-template>
			<xsl:call-template name="p:output_def">
				<xsl:with-param name="def" select="substring-before($arg, '; ')"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<xsl:call-template name="p:output_def">
				<xsl:with-param name="def" select="$arg"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="p:output_def">
	<xsl:param name="def"/>

	<xsl:variable name="name" select="substring-before($def, ' ')"/>
	<xsl:variable name="value" select="substring-after($def, ' ')"/>

	<__x:variable name="{$name}" select="{$value}"/>
</xsl:template>

<!--
 ! tal:condition
 !-->
<xsl:template mode="tal" priority="60"
							match="*[@tal:condition]"
							name="tal_condition"
>
	<__x:if test="{@tal:condition}">
		<xsl:choose>
			<xsl:when test="@tal:repeat">
				<xsl:call-template name="p:tal_repeat"/>
			</xsl:when>
			<xsl:when test="@tal:content">
				<xsl:call-template name="p:tal_content"/>
			</xsl:when>
			<xsl:when test="@tal:replace">
				<xsl:call-template name="p:tal_replace"/>
			</xsl:when>
			<xsl:when test="@tal:omit-tag">
				<xsl:call-template name="p:tal_omit-tag"/>
			</xsl:when>
			<xsl:otherwise>
				<xsl:call-template name="p:copy-element"/>
			</xsl:otherwise>
		</xsl:choose>
	</__x:if>
</xsl:template>

<!--
 ! tal:repeat
 !-->
<xsl:template mode="tal" priority="50"
							match="*[@tal:repeat]"
							name="p:tal_repeat"
>
	<xsl:variable name="name" select="substring-before(@tal:repeat, ' ')"/>
	<xsl:variable name="node-set" select="substring-after(@tal:repeat, ' ')"/>

	<__x:if test="not(xtal:nothing({$node-set}))">
		<__x:for-each select="{$node-set}">
			<__x:variable name="{$name}" select="."/>
			<xsl:choose>
				<xsl:when test="@tal:content">
					<xsl:call-template name="p:tal_content"/>
				</xsl:when>
				<xsl:when test="@tal:replace">
					<xsl:call-template name="p:tal_replace"/>
				</xsl:when>
				<xsl:when test="@tal:omit-tag">
					<xsl:call-template name="p:tal_omit-tag"/>
				</xsl:when>
				<xsl:otherwise>
					<xsl:call-template name="p:copy-element"/>
				</xsl:otherwise>
			</xsl:choose>
		</__x:for-each>
	</__x:if>
</xsl:template>

<!--
 ! tal:content & tal:replace
 !-->
<xsl:template mode="tal" priority="30"
							match="*[@tal:content]"
							name="p:tal_content"
>
	<xsl:choose>
		<xsl:when test="not(@tal:omit-tag)">
			<xsl:copy>
				<xsl:apply-templates mode="tal" select="@*"/>

				<xsl:call-template name="p:content-replace">
					<xsl:with-param name="arg" select="@tal:content"/>
				</xsl:call-template>
			</xsl:copy>
		</xsl:when>
		<xsl:when test="normalize-space(@tal:omit-tag) = ''">
			<xsl:call-template name="p:content-replace">
				<xsl:with-param name="arg" select="@tal:content"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:otherwise>
			<__x:choose>
				<__x:when test="{@tal:omit-tag}">
					<xsl:call-template name="p:content-replace">
						<xsl:with-param name="arg" select="@tal:content"/>
					</xsl:call-template>
				</__x:when>
				<__x:otherwise>
					<xsl:copy>
						<xsl:apply-templates mode="tal" select="@*"/>

						<xsl:call-template name="p:content-replace">
							<xsl:with-param name="arg" select="@tal:content"/>
						</xsl:call-template>
					</xsl:copy>
				</__x:otherwise>
			</__x:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template mode="tal" priority="30"
							match="*[@tal:replace]"
							name="p:tal_replace"
>
	<xsl:call-template name="p:content-replace">
		<xsl:with-param name="arg" select="@tal:replace"/>
	</xsl:call-template>
</xsl:template>

<xsl:template name="p:content-replace">
	<xsl:param name="arg"/>

	<xsl:variable name="mode" select="substring-before($arg, ' ')"/>
	<xsl:variable name="xpath" select="substring-after($arg, ' ')"/>

	<xsl:choose>
		<xsl:when test="$mode = ''">
			<xsl:call-template name="p:content-replace-argument">
				<xsl:with-param name="xpath" select="$arg"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="$mode = 'text'">
			<xsl:call-template name="p:content-replace-argument">
				<xsl:with-param name="xpath" select="$xpath"/>
			</xsl:call-template>
		</xsl:when>
		<xsl:when test="$mode = 'structure'">
			<xsl:call-template name="p:content-replace-argument">
				<xsl:with-param name="xpath" select="$xpath"/>
				<xsl:with-param name="structure" select="true()"/>
			</xsl:call-template>
		</xsl:when>
	</xsl:choose>
</xsl:template>

<xsl:template name="p:content-replace-argument">
	<xsl:param name="xpath"/>
	<xsl:param name="structure" select="false()"/>

	<__x:choose>
		<__x:when test="xtal:nothing({$xpath})">
			<!-- remove -->
		</__x:when>
		<__x:when test="xtal:default({$xpath})">
			<xsl:apply-templates mode="tal"/>
		</__x:when>
		<__x:otherwise>
			<xsl:choose>
				<xsl:when test="$structure">
					<__x:apply-templates select="{$xpath}"/>
				</xsl:when>
				<xsl:otherwise>
					<__x:value-of select="{$xpath}"/>
				</xsl:otherwise>
			</xsl:choose>
		</__x:otherwise>
	</__x:choose>
</xsl:template>

<!--
 ! tal:omit-tag
 !-->
<xsl:template mode="tal" priority="20"
							match="*[@tal:omit-tag]"
							name="p:tal_omit-tag"
>
	<xsl:choose>
		<xsl:when test="normalize-space(@tal:omit-tag) = ''">
			<xsl:apply-templates mode="tal"/>
		</xsl:when>
		<xsl:otherwise>
			<__x:choose>
				<__x:when test="{@tal:omit-tag}">
					<xsl:apply-templates mode="tal"/>
				</__x:when>
				<__x:otherwise>
					<xsl:call-template name="p:copy-element"/>
				</__x:otherwise>
			</__x:choose>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<!--~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
 ! statements (attributes)
 !~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~-->

<!--
 ! tal:attributes
 !-->
<xsl:template mode="tal" match="@tal:on-error">
	<xsl:message terminate="yes">&MSG2;</xsl:message>
</xsl:template>

<xsl:template mode="tal"
							match="@tal:define | @tal:condition | @tal:repeat |
									   @tal:content | @tal:replace | @tal:omit-tag">
	<!-- ignore -->
</xsl:template>

<xsl:template mode="tal" match="@tal:attributes">
	<xsl:call-template name="p:attributes">
		<xsl:with-param name="arg" select="normalize-space(.)"/>
	</xsl:call-template>
</xsl:template>

<xsl:template name="p:attributes">
	<xsl:param name="arg"/>

	<xsl:choose>
		<xsl:when test="contains($arg, '; ')">
			<xsl:call-template name="p:attributes">
				<xsl:with-param name="arg" select="substring-after($arg, '; ')"/>
			</xsl:call-template>
			<xsl:call-template name="p:output_attr">
				<xsl:with-param name="attr" select="substring-before($arg, '; ')"/>
			</xsl:call-template>
		</xsl:when>

		<xsl:otherwise>
			<xsl:call-template name="p:output_attr">
				<xsl:with-param name="attr" select="$arg"/>
			</xsl:call-template>
		</xsl:otherwise>
	</xsl:choose>
</xsl:template>

<xsl:template name="p:output_attr">
	<xsl:param name="attr"/>

	<xsl:variable name="name" select="substring-before($attr, ' ')"/>
	<xsl:variable name="value" select="substring-after($attr, ' ')"/>

	<__x:choose>
		<__x:when test="xtal:nothing({$value})">
			<!-- set null (cannot remove) -->
			<__x:attribute name="{$name}"/>
		</__x:when>
		<__x:when test="xtal:default({$value})">
			<!-- do not touch -->
		</__x:when>
		<__x:otherwise>
			<__x:attribute name="{$name}">
				<__x:value-of select="{$value}"/>
			</__x:attribute>
		</__x:otherwise>
	</__x:choose>
</xsl:template>

<xsl:template mode="tal" match="*">
	<xsl:copy>
		<xsl:apply-templates mode="tal" select="@*"/>

		<xsl:apply-templates mode="tal"/>
	</xsl:copy>
</xsl:template>

<xsl:template mode="tal" match="@*">
		<xsl:copy/>
</xsl:template>

<xsl:template mode="tal" match="processing-instruction()">
	<__x:processing-instruction name="{name()}">
		<xsl:value-of select="."/>
	</__x:processing-instruction>
</xsl:template>

</xsl:transform>
<!--
vim:ts=2:sw=2:ai:nowrap
-->
