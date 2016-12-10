<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" 
	xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
	xmlns:oai="http://www.openarchives.org/OAI/2.0/"
	version="1.0">
	<xsl:output method="text" omit-xml-declaration="yes"/>
	<xsl:param name="data"/>
	<xsl:template match="/">
		<xsl:choose>
			<xsl:when test="$data='remote-id'">
				<!-- only get the first one -->
				<xsl:if test="/pkgmetadata/upstream/remote-id">
					<xsl:value-of select="/pkgmetadata/upstream/remote-id/@type"/>
					<xsl:text>:</xsl:text>
					<xsl:value-of select="/pkgmetadata/upstream/remote-id"/>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
		<xsl:choose>
			<xsl:when test="$data='remote-ids'">
				<xsl:if test="/pkgmetadata/upstream/remote-id">
					<xsl:for-each select="/pkgmetadata/upstream/remote-id">
						<xsl:value-of select="@type"/>
						<xsl:text>:</xsl:text>
						<xsl:value-of select="."/>
						<xsl:text>&#xA;</xsl:text>
					</xsl:for-each>
				</xsl:if>
			</xsl:when>
		</xsl:choose>
	</xsl:template>
</xsl:stylesheet>
