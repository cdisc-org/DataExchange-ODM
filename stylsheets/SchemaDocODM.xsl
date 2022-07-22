<?xml version="1.0" encoding="UTF-8"?>
<xsl:stylesheet version="1.0" xmlns:xsl="http://www.w3.org/1999/XSL/Transform"
	xmlns:xs="http://www.w3.org/2001/XMLSchema" xmlns:odm="http://www.cdisc.org/ns/odm/v2.0"
	xml:lang="en" exclude-result-prefixes="xs odm">

	<xsl:output method="html" indent="yes" encoding="utf-8"
		doctype-system="http://www.w3.org/TR/html4/strict.dtd"
		doctype-public="-//W3C//DTD HTML 4.01//EN" version="4.0"/>

	<xsl:key name="elements" match="xs:element[@name]" use="concat('def:', @name)"/>
	<xsl:key name="complexTypes" match="xs:complexType[@name]" use="concat('def:', @name)"/>
	<xsl:key name="simpleTypes" match="xs:simpleType[@name]" use="concat('def:', @name)"/>

	<xsl:param name="title"/>

	<xsl:template match="/">
		<xsl:comment>ODM Schemadoc 0.1</xsl:comment>

		<html>
			<head>
				<xsl:if test="$title != ''">
					<title>
						<xsl:value-of select="$title"/>
					</title>
				</xsl:if>
				<xsl:call-template name="GenerateCSS"/>
			</head>
			<body>

				<div id="menu">

					<h2>Enumerations</h2>
					<div class="section element-list">
						<ul>
							<xsl:for-each select="xs:schema/xs:simpleType[@name]">
								<!--<xsl:sort select="@name"/>-->
								<li>
									<xsl:variable name="enumerationqname">def:<xsl:value-of
											select="@name"/></xsl:variable>
									<a href="#attribute-{$enumerationqname}">
										<xsl:value-of select="@name"/>
									</a>
								</li>
							</xsl:for-each>
						</ul>
					</div>

				</div>
				<div id="main">

					<xsl:if test="xs:schema/xs:annotation">
						<h3>
							<xsl:value-of select="xs:schema/xs:annotation/xs:documentation"/>
						</h3>
					</xsl:if>
					<xsl:if test="xs:schema/@version">
						<h3>Schema version: <xsl:value-of select="xs:schema/@version"/></h3>
					</xsl:if>

					<xsl:apply-templates select="//xs:schema" mode="types"/>
				</div>

			</body>
		</html>
	</xsl:template>

	<xsl:template match="xs:schema" mode="elements">
		<div class="section">
			<xsl:apply-templates select="xs:element[@name]"/>
		</div>
	</xsl:template>

	<xsl:template match="xs:element">
		<xsl:variable name="elementqname">def:<xsl:value-of select="@name"/></xsl:variable>
		<div class="element">
			<h4>
				<a id="element-{$elementqname}">
					<xsl:value-of select="@name"/>
				</a>
			</h4>

			<xsl:for-each select="key('complexTypes', @type)">
				<span class="description">
					<xsl:value-of select="xs:annotation/xs:documentation"/>
				</span>

				<div class="element-children">
					<xsl:choose>
						<xsl:when test=".//xs:element">
							<h5>Child elements</h5>
							<table>
								<caption>Child elements</caption>
								<tr>
									<th class="name">Name</th>
									<th class="min">Min. # Occurrences</th>
									<th class="max">Max. # Occurrences</th>
									<th class="description">Description</th>
								</tr>
								<xsl:for-each select=".//xs:element">
									<tr>
										<td class="name">
											<xsl:choose>
												<xsl:when test="@name">
												<xsl:value-of select="@name"/>
												</xsl:when>
												<xsl:when test="key('elements', @ref)">
												<a href="#element-{@ref}">
												<xsl:value-of select="@ref"/>
												</a>
												</xsl:when>
												<xsl:otherwise>
												<xsl:value-of select="@ref"/>
												</xsl:otherwise>
											</xsl:choose>
										</td>
										<td class="min">
											<xsl:value-of select="@minOccurs"/>
										</td>
										<td class="max">
											<xsl:value-of select="@maxOccurs"/>
										</td>
										<td class="description">
											<xsl:value-of select="xs:annotation/xs:documentation"/>
										</td>
									</tr>
								</xsl:for-each>
							</table>
						</xsl:when>
						<xsl:otherwise>
							<h5>No child elements.</h5>
						</xsl:otherwise>
					</xsl:choose>
				</div>

				<div class="element-attributes">
					<xsl:choose>
						<xsl:when test=".//xs:attribute">
							<h5>Attributes</h5>
							<table>
								<caption>Attributes</caption>
								<tr>
									<th class="name">Name</th>
									<th class="type">Type</th>
									<th class="use">Use</th>
									<th class="description">Description</th>
								</tr>
								<xsl:for-each select=".//xs:attribute">
									<tr>
										<td class="name">
											<xsl:choose>
												<xsl:when test="@ref">
												<xsl:value-of select="@ref"/>
												</xsl:when>
												<xsl:when test="@name">
												<xsl:value-of select="@name"/>
												</xsl:when>
											</xsl:choose>
										</td>
										<td class="min">
											<xsl:choose>
												<xsl:when test="key('simpleTypes', @type)">
												<a href="#type-{@type}">
												<xsl:value-of select="@type"/>
												</a>
												</xsl:when>
												<xsl:otherwise>
												<xsl:value-of select="@type"/>
												</xsl:otherwise>
											</xsl:choose>
										</td>
										<td class="max">
											<xsl:value-of select="@use"/>
										</td>
										<td class="description">
											<xsl:value-of select="xs:annotation/xs:documentation"/>
										</td>
									</tr>
								</xsl:for-each>
							</table>
						</xsl:when>
						<xsl:otherwise>
							<h5>No attributes.</h5>
						</xsl:otherwise>
					</xsl:choose>
				</div>
			</xsl:for-each>

			<xsl:if test="//xs:element[@ref = $elementqname]">
				<div class="use">
					<h5>Used in:</h5>
					<xsl:for-each select="//xs:element[@ref = $elementqname]">
						<xsl:if test="position() > 1">; </xsl:if>

						<xsl:variable name="typename">def:<xsl:value-of
								select="./ancestor::*[name() = 'xs:complexType']/@name"
							/></xsl:variable>
						<xsl:variable name="element" select="//xs:element[@type = $typename]"/>
						<a href="#element-{$elementqname}">
							<xsl:value-of select="$element/@name"/>
						</a>
					</xsl:for-each>
				</div>
			</xsl:if>
		</div>
	</xsl:template>

	<xsl:template match="xs:schema" mode="attributes">
		<div class="element">
			<table>
				<caption>Attributes</caption>
				<tr>
					<th class="name">Name</th>
					<th class="type">Type</th>
					<th class="description">Description</th>
				</tr>

				<xsl:apply-templates select="xs:attribute[@name]"/>
			</table>
		</div>
	</xsl:template>

	<xsl:template match="xs:attribute">
		<xsl:variable name="attributeqname">def:<xsl:value-of select="@name"/></xsl:variable>
		<tr>
			<td>
				<a id="attribute-{$attributeqname}">
					<xsl:value-of select="@name"/>
				</a>
			</td>
			<td>
				<xsl:value-of select="@type"/>
			</td>
			<td>
				<xsl:value-of select="xs:annotation/xs:documentation"/>
			</td>
		</tr>
	</xsl:template>


	<xsl:template match="xs:schema" mode="types">
		<xsl:if test="xs:simpleType">
			<div class="types">
				<table>
					<tr class="header">
						<th>Name</th>
						<th>Description [NCI Code]</th>
						<th>Type</th>
						<th>Extensible</th>
						<th>Permitted Values [NCI Code]</th>
					</tr>
					<xsl:apply-templates select="xs:simpleType"/>
				</table>
			</div>
		</xsl:if>
	</xsl:template>

	<xsl:template match="xs:simpleType">
		<xsl:variable name="enumerationqname">def:<xsl:value-of select="@name"/></xsl:variable>
		<tr>

			<xsl:call-template name="setRowClassOddeven">
				<xsl:with-param name="rowNum" select="position()"/>
			</xsl:call-template>

			<td class="name">
				<a id="attribute-{$enumerationqname}"/>
				<a id="type-def:{@name}">
					<xsl:value-of select="@name"/>
				</a>
			</td>

			<td class="description">
				<xsl:value-of select="xs:annotation/xs:documentation"/>
				<xsl:if test="xs:annotation/xs:appinfo/odm:Alias/@Context = 'nci:ExtCodeID'">
					<xsl:text> [</xsl:text>
					<span class="nci">
						<xsl:value-of select="xs:annotation/xs:appinfo/odm:Alias/@Name"/>
					</span>
					<xsl:text>]</xsl:text>
				</xsl:if>
			</td>

			<xsl:choose>
				<xsl:when test="xs:restriction/xs:enumeration">
					<td class="type">Enumeration</td>
					<td class="extensible">No</td>
					<td class="values">
						<xsl:for-each select="xs:restriction/xs:enumeration">
							<xsl:if test="position() > 1">
								<br/>
							</xsl:if>
							<span class="code">
								<xsl:text>'</xsl:text>
								<xsl:value-of select="@value"/>
								<xsl:text>'</xsl:text>
								<xsl:if
									test="xs:annotation/xs:appinfo/odm:Alias/@Context = 'nci:ExtCodeID'">
									<xsl:text> [</xsl:text>
									<span class="nci">
										<xsl:value-of select="xs:annotation/xs:appinfo/odm:Alias/@Name"
										/>
									</span>
									<xsl:text>]</xsl:text>
								</xsl:if>
							</span>
						</xsl:for-each>
					</td>
				</xsl:when>
				<xsl:when test="xs:union/xs:simpleType/xs:restriction/xs:enumeration">
					<td class="type">Enumeration</td>
					<td class="extensible">Yes (<xsl:value-of
							select="xs:union/xs:simpleType/xs:restriction/@base"/>)</td>
					<td class="values">
						<xsl:for-each select="xs:union/xs:simpleType/xs:restriction/xs:enumeration">
							<xsl:if test="position() > 1">
								<br/>
							</xsl:if>
							<span class="code">
								<xsl:text>'</xsl:text>
								<xsl:value-of select="@value"/>
								<xsl:text>'</xsl:text>
								<xsl:if
									test="xs:annotation/xs:appinfo/odm:Alias/@Context = 'nci:ExtCodeID'">
									<xsl:text> [</xsl:text>
									<span class="nci">
										<xsl:value-of select="xs:annotation/xs:appinfo/odm:Alias/@Name"
										/>
									</span>
									<xsl:text>]</xsl:text>
								</xsl:if>
							</span>
						</xsl:for-each>
					</td>
				</xsl:when>
				<xsl:when test="xs:union/xs:simpleType/xs:restriction">
					<td class="type">Enumeration</td>
					<td class="extensible">No</td>
					<td class="values">
						<xsl:for-each select="xs:union/xs:simpleType/xs:restriction">
							<xsl:if test="position() > 1">
								<br/>
							</xsl:if>
							<span class="code">
								<xsl:value-of select="@base"/>
							</span>
						</xsl:for-each>
					</td>
				</xsl:when>
				<xsl:when test="xs:restriction/xs:pattern">
					<td class="type">Pattern</td>
					<td class="extensible">No (<xsl:value-of
						select="xs:restriction/@base"/>)</td>
					<td class="definition"><span class="code">
						 <xsl:value-of select="xs:restriction/xs:pattern/@value"/></span>
					</td>
				</xsl:when>
				<xsl:otherwise>
					<xsl:message terminate="no">!!! type not handled in schemadoc !!!</xsl:message>
				</xsl:otherwise>
			</xsl:choose>
		</tr>
	</xsl:template>

	<!-- ************************************************************* -->
	<!-- Template:    setRowClassOddeven                               -->
	<!-- Description: This template sets the table row class attribute -->
	<!--              based on the specified table row number          -->
	<!-- ************************************************************* -->
	<xsl:template name="setRowClassOddeven">
		<!-- rowNum: current table row number (1-based) -->
		<xsl:param name="rowNum"/>

		<!-- set the class attribute to "tableroweven" for even rows, "tablerowodd" for odd rows -->
		<xsl:attribute name="class">
			<xsl:choose>
				<xsl:when test="$rowNum mod 2 = 0">
					<xsl:text>tableroweven</xsl:text>
				</xsl:when>
				<xsl:otherwise>
					<xsl:text>tablerowodd</xsl:text>
				</xsl:otherwise>
			</xsl:choose>
		</xsl:attribute>
	</xsl:template>


	<!-- ************************************************************* -->
	<!-- Template: "GenerateCSS"                                       -->
	<!-- ************************************************************* -->
		<xsl:template name="GenerateCSS">
			<xsl:variable name="COLOR_MENU_BODY_BACKGROUND">#FFFFFF</xsl:variable>
			<xsl:variable name="COLOR_CAPTION">#696969</xsl:variable>
			<xsl:variable name="COLOR_BORDER">#000000</xsl:variable>
			<xsl:variable name="COLOR_TABLE_BACKGROUND">#EEEEEE</xsl:variable>  
			<xsl:variable name="COLOR_TR_HEADER_BACK">#6699CC</xsl:variable>  
			<xsl:variable name="COLOR_TR_HEADER">#FFFFFF</xsl:variable>  
			<xsl:variable name="COLOR_TABLEROW_ODD">#FFFFFF</xsl:variable>
			<xsl:variable name="COLOR_TABLEROW_EVEN">#EEEEEE</xsl:variable>
			<xsl:variable name="COLOR_TR_VLM_BACK">#D3D3D3</xsl:variable>  
			
	  <style type="text/css">
			#menu {
			  position: fixed;
			  left: 10px;
			  top: 10px;
			  width: 15%;
			  height: 96%;
			  bottom: 0px;
			  overflow: auto;
			  background-color: #FFFFFF;
			  color: #000000;
			  border: 0px none black;
			  text-align: left;
			  white-space: nowrap;
			}
			
			#main {
			  position: absolute;
			  left: 17%;
			  overflow: auto;
			  color: #000000;
			  background-color: #FFFFFF;
			  float: none !important;
			}
			
			table {
			  border-collapse: collapse;
			  border-spacing: 0;
			}
			
			th {
			  padding: 4px;
			  text-align: left;
			  font-weight: bold;
			}
			
			td {
			  padding: 4px;
			  text-align: left;
			  font-weight: normal;
			}
			
			ol,
			ul {
			  list-style: none;
			  padding: 5px;
			  margin-left: 0;
			}
		  
			body {
			background-color: <xsl:value-of select="$COLOR_MENU_BODY_BACKGROUND"/>;
		  font-family: Verdana, Arial, Helvetica, sans-serif;
			font-style:  normal;
			font-weight: normal;
			font-size: 62.5%;
			padding: 10px;
			}
			
			h1{
			font-size: 1.6em;
			margin-left: 0;
			font-weight: bolder;
			text-align: left;
			color: <xsl:value-of select="$COLOR_CAPTION"/>;
		  }
		  
			h2 {
			font-size: 1.5em;
			margin-left: 0;
			font-weight: bolder;
			text-align: left;
			color: <xsl:value-of select="$COLOR_CAPTION"/>;
		  }
			
			h3 {
			font-size: 1.4em;
			margin-left: 0;
			font-weight: bolder;
			text-align: left;
			color: <xsl:value-of select="$COLOR_CAPTION"/>;
		  }
			
			h4 {
			font-size: 1.3em;
			margin-left: 0;
			font-weight: bolder;
			text-align: left;
			color: <xsl:value-of select="$COLOR_CAPTION"/>;
		  }
			
			h5 {
			font-size: 1.2em;
			margin-left: 0;
			font-weight: bolder;
			text-align: left;
			color: <xsl:value-of select="$COLOR_CAPTION"/>;
		  }
			
			.element-list ul {
			list-style: disc;
			margin-left: 5px;
			}
			
			.element-list li {
			padding-left: 5px;
			font-size: 1.3em;
			}
			
			.element, 
			.types {
			margin: 10px 20px 20px 20px;
			}
			
			.element div {
			margin: 10px 20px 10px 20px;
			}
			
			.element table {
			margin-top: 5px;
			}
			
			table{
			width: 95%;
			border-spacing: 4px;
			border: 1px solid <xsl:value-of select="$COLOR_BORDER"/>;
		  background-color: <xsl:value-of select="$COLOR_TABLE_BACKGROUND"/>;
		  margin-top: 5px;
		  border-collapse: collapse;
		  padding: 5px;
		  empty-cells: show;
		  }
		  
			table tr{
			border: 1px solid <xsl:value-of select="$COLOR_BORDER"/>;
		  }
		  
		  table tr.header{
		  background-color: <xsl:value-of select="$COLOR_TR_HEADER_BACK"/>;
		  color: <xsl:value-of select="$COLOR_TR_HEADER"/>;
		  font-weight: bold;
		  }
		  
		  tr.tablerowodd{
		  background-color: <xsl:value-of select="$COLOR_TABLEROW_ODD"/>;
		  }
		  tr.tableroweven{
		  background-color: <xsl:value-of select="$COLOR_TABLEROW_EVEN"/>;
		  }

		  table th{
			font-weight: bold;
			vertical-align: top;
			text-align: left;
			padding: 5px;
			border: 1px solid <xsl:value-of select="$COLOR_BORDER"/>;
		  font-size: 1.3em;
		  }
		  
		  table td{
		  vertical-align: top;
		  padding: 5px;
		  border: 1px solid <xsl:value-of select="$COLOR_BORDER"/>;
		  font-size: 1.2em;
		  line-height: 150%;
		  }
		  
		  .element td.name { width: 20%; }
		  .element td.min, td.max, td.use { width: 15%; }
		  .element td.type { width: 10%; }
		  .element td.description { width: 50%; }
			.element td.extensible {}
			.element td.values {white-space: nowrap;}
			
			caption {
			display: none;
			}
			
			.use h5 {
			display: inline;
			}
			
			.heading {
			font-weight: bold;
			}
			
			.types td.name { width: 15%; }
			.types td.description { width: 30%; }
			.types td.type { width: 10%; }
			.types td.definition { width: 45%; }
		
	  	<!-- Specific print styling -->
	  	@media print{
	  	
	  	@page {
	  	margin: 1.5cm;
	  	}
	  	
	  	body,
	  	h1,
	  	table caption,
	  	table caption.header{
	  	color: #000;
	  	background: #fff;
	  	float: none !important;
	  	}
	  	
	  	
	  	table{
	  	border-width: 2px;
	  	}
	  	
	  	#menu{
	  	display: none !important;
	  	width: 0px;
	  	}
	  	#main{
	  	left: 2cm;
	  	float: none !important;
	  	}
	  	
	  	row, ul, img {
	  	page-break-inside: avoid;
	  	}
	  	
	  	}
	  </style>
	</xsl:template>

</xsl:stylesheet>
