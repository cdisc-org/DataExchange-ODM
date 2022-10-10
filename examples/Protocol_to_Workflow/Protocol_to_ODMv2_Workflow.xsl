<?xml version="1.0" encoding="UTF-8"?>
<!-- A stylesheet to transform the old ODM "Protocol" element with StudyEventRefs,
	to a (very simple, linear) ODMv2 "Workflow".
	This stylesheet can be used as a start to build considerably 
	more complex workflows, e.g. with branches, cycles, etc ... -->
<!-- This XSLT is limited to Study definition only, 
		so not meant to be used with AdminData, ReferenceData, ClinicalData, etc. -->
<!-- Remark that the workflow is limited to the StudyEventDefs that are "Scheduled" -->
<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" version="1.0"
	xmlns:odm="http://www.cdisc.org/ns/odm/v1.3" xmlns:odmv2="http://www.cdisc.org/ns/odm/v2.0">
	
	<!-- pretty print -->
	<xsl:output method="xml" indent="yes"/>
	<!-- a variable keeping the ODMv2 namespace -->
	<xsl:variable name="ODMv2NS">http://www.cdisc.org/ns/odm/v2.0</xsl:variable>
	
	<xsl:template match="/">
		<xsl:apply-templates/>
	</xsl:template>
	
	<!-- ODM element: move to ODMv2 namespace -->
	<!-- Copy the attributes except for "Description" and "ODMVersion" -->
	<xsl:template match="odm:ODM">
		<xsl:element name="ODM" namespace="{$ODMv2NS}">
			<xsl:for-each select="@*[not(name()='Description')][not(name()='ODMVersion')]"><xsl:copy-of select="."/></xsl:for-each>
			<!-- Add the ODMVersion attribute -->
			<xsl:attribute name="ODMVersion">2.0</xsl:attribute>
			<!-- Move the "Description" attribute to a child element -->
			<xsl:if test="@Description">
				<xsl:element name="Description" namespace="{$ODMv2NS}">
					<xsl:element name="TranslatedText" namespace="{$ODMv2NS}">
						<xsl:attribute name="type">text/plain</xsl:attribute>
						<xsl:value-of select="@Description"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<xsl:apply-templates/>
		</xsl:element>
	</xsl:template>
	
	<!-- Study element, make deep copy to ODMv2, except for "MetaDataVersion" element -->
	<xsl:template match="odm:Study">
		<!-- first move to ODMv2 namespace -->
		<xsl:element name="Study" namespace="{$ODMv2NS}">
			<xsl:for-each select="@*"><xsl:copy-of select="."/></xsl:for-each>
			<!-- REMARK that we do not have "GlobalVariables" and "BasicDefinitions" in ODMv2 anymore, so that part is NOT copied -->
			<!--xsl:for-each select="odm:GlobalVariables">
				<xsl:call-template name="makedeepcopy_to_ODMv2"/>
			</xsl:for-each-->
			<!--xsl:for-each select="odm:BasicDefinitions">
				<xsl:call-template name="makedeepcopy_to_ODMv2"/>
			</xsl:for-each-->
			<!-- Instead we have "StudyName" and "ProtocolName" as attributes on the ODM element -->
			<xsl:attribute name="StudyName"><xsl:value-of select="odm:GlobalVariables/odm:StudyName"/></xsl:attribute>
			<xsl:attribute name="ProtocolName"><xsl:value-of select="odm:GlobalVariables/odm:ProtocolName"/></xsl:attribute>
			<xsl:for-each select="odm:MetaDataVersion">
				<xsl:call-template name="odm:MetaDataVersion"/>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
	<!-- makes a deep copy moving everything to the ODMv2 namespace -->
	<xsl:template name="makedeepcopy_to_ODMv2">
		<!-- 2022-10-04: we need to replace FormRef by ItemGroupDef and FormDef by ItemGroupDef with attribute "Type" with the value "Form" -->
		<xsl:choose>
			<xsl:when test="name()='FormRef'">
				<xsl:element name="ItemGroupRef" namespace="{$ODMv2NS}">
					<!-- and just copy the attributes, except for FormOID -->
					<xsl:for-each select="@*[not(name()='FormOID')]"><xsl:copy-of select="."/></xsl:for-each>
					<!-- and add the attribute "ItemGroupOID" -->
					<xsl:attribute name="ItemGroupOID"><xsl:value-of select="@FormOID"/></xsl:attribute>
					<!-- make a deep copy of the child elements in the new namespace
						(uses recursion) -->
					<xsl:for-each select="./*">
						<xsl:call-template name="makedeepcopy_to_ODMv2"/>
					</xsl:for-each>
				</xsl:element>
			</xsl:when>
			<xsl:when test="name()='FormDef'">
				<xsl:element name="ItemGroupDef" namespace="{$ODMv2NS}">
					<!-- just copy the attributes -->
					<xsl:for-each select="@*"><xsl:copy-of select="."/></xsl:for-each>
					<!-- and add a "Type" attribute with value "Form" -->
					<xsl:attribute name="Type">Form</xsl:attribute>
					<!-- If there is an attribute "Repeating" with value "Yes", replace the value by "Simple" -->
					<xsl:if test="@Repeating='Yes'">
						<xsl:attribute name="Repeating">Simple</xsl:attribute>
					</xsl:if>
					<!-- make a deep copy of the child elements in the new namespace
						(uses recursion) -->
					<xsl:for-each select="./*">
						<xsl:call-template name="makedeepcopy_to_ODMv2"/>
					</xsl:for-each>
				</xsl:element>
			</xsl:when>
			<xsl:when test="name()='ItemGroupDef'">
				<xsl:element name="ItemGroupDef" namespace="{$ODMv2NS}">
					<!-- copy all the attributes, except for SASDatasetName -->
					<xsl:for-each select="@*[not(name()='SASDatasetName')]"><xsl:copy-of select="."/></xsl:for-each>
					<!-- If there is an attribute "Repeating" with value "Yes", replace the value by "Simple" -->
					<xsl:if test="@Repeating='Yes'">
						<xsl:attribute name="Repeating">Simple</xsl:attribute>
					</xsl:if>
					<!-- Move the value of @SASDatasetName to the new attribute DatasetName -->
					<xsl:if test="@SASDatasetName">
						<xsl:attribute name="DatasetName"><xsl:value-of select="@SASDatasetName"/></xsl:attribute>
					</xsl:if>
					<!-- Add the "Type" attribute with value "Section" -->
					<xsl:attribute name="Type">Section</xsl:attribute>
					<!-- make a deep copy of the child elements in the new namespace
						(uses recursion) -->
					<xsl:for-each select="./*">
						<xsl:call-template name="makedeepcopy_to_ODMv2"/>
					</xsl:for-each>
				</xsl:element>
			</xsl:when>
			<!-- ItemDef -->
			<xsl:when test="name()='ItemDef'">
				<xsl:element name="ItemDef" namespace="{$ODMv2NS}">
					<!-- copy all attributes, except for SDSVarName and SASFieldName and SignificantDigits -->
					<xsl:for-each select="@*[not(name()='SASFieldName')][not(name()='SDSVarName')][not(name()='SignificantDigits')]"><xsl:copy-of select="."/></xsl:for-each>
					<!-- make a deep copy of the child elements in the new namespace
							(uses recursion) -->
					<xsl:for-each select="./*">
						<xsl:call-template name="makedeepcopy_to_ODMv2"/>
					</xsl:for-each>
					<!-- Move the value of "SDSVarName" to an "Alias" with @Context=SDTM, 
						except when already present -->
					<xsl:if test="@SDSVarName and not(./odm:Alias[@Context='SDTM'])">
						<xsl:element name="Alias" namespace="{$ODMv2NS}">
							<xsl:attribute name="Context">SDTM</xsl:attribute>
							<xsl:attribute name="Name"><xsl:value-of select="@SDSVarName"/></xsl:attribute>
						</xsl:element>
					</xsl:if>
				</xsl:element>
			</xsl:when>
			<!-- CodeList -->
			<xsl:when test="name()='CodeList'">
				<xsl:element name="CodeList" namespace="{$ODMv2NS}">
					<!-- copy all attributes, except for SASFormatName -->
					<xsl:for-each select="@*[not(name()='SASFormatName')]"><xsl:copy-of select="."/></xsl:for-each>
					<!-- make a deep copy of the child elements in the new namespace
							(uses recursion) -->
					<xsl:for-each select="./*">
						<xsl:call-template name="makedeepcopy_to_ODMv2"/>
					</xsl:for-each>
				</xsl:element>
			</xsl:when>
			<!-- ConditionDef: we need to insert an empty "MethodSignature" element -->
			<xsl:when test="name()='ConditionDef'">
				<xsl:element name="ConditionDef" namespace="{$ODMv2NS}">
					<!-- copy all attributes -->
					<xsl:for-each select="@*"><xsl:copy-of select="."/></xsl:for-each>
					<!-- copy the Description child element, remark that it needs adaption for TranslatedText -->
					<xsl:for-each select="odm:Description">
						<xsl:call-template name="makedeepcopy_to_ODMv2"/>
					</xsl:for-each>
					<!-- Insert an empty MethodSignature element -->
					<xsl:element name="MethodSignature" namespace="{$ODMv2NS}"/>
					<!-- copy the FormalExpression element. Remark that it requires adaption -->
					<xsl:for-each select="odm:FormalExpression">
						<xsl:call-template name="makedeepcopy_to_ODMv2"/>
					</xsl:for-each>
					<!-- copy any Alias elements -->
					<xsl:for-each select="odm:Alias">
						<xsl:call-template name="makedeepcopy_to_ODMv2"/>
					</xsl:for-each>
				</xsl:element>
			</xsl:when>
			<!-- MethodDef: we need to insert an empty "MethodSignature" element -->
			<xsl:when test="name()='MethodDef'">
				<xsl:element name="MethodDef" namespace="{$ODMv2NS}">
					<!-- copy all attributes -->
					<xsl:for-each select="@*"><xsl:copy-of select="."/></xsl:for-each>
					<!-- copy the Description child element, remark that it needs adaption for TranslatedText -->
					<xsl:for-each select="odm:Description">
						<xsl:call-template name="makedeepcopy_to_ODMv2"/>
					</xsl:for-each>
					<!-- Insert an empty MethodSignature element -->
					<xsl:element name="MethodSignature" namespace="{$ODMv2NS}"/>
					<!-- copy the FormalExpression element. Remark that it requires adaption -->
					<xsl:for-each select="odm:FormalExpression">
						<xsl:call-template name="makedeepcopy_to_ODMv2"/>
					</xsl:for-each>
					<!-- copy any Alias elements -->
					<xsl:for-each select="odm:Alias">
						<xsl:call-template name="makedeepcopy_to_ODMv2"/>
					</xsl:for-each>
				</xsl:element>
			</xsl:when>
			<!-- FormalExpression: text content is not allowed anymore, goes into the "Code" element -->
			<xsl:when test="name()='FormalExpression'">
				<xsl:element name="FormalExpression" namespace="{$ODMv2NS}">
					<!-- Copy the Context attribute -->
					<xsl:copy-of select="@Context"/>
					<!-- and the text content goes into the new "Code" element -->
					<xsl:element name="Code" namespace="{$ODMv2NS}">
						<xsl:value-of select="."/>
					</xsl:element>
				</xsl:element>
			</xsl:when>
			<!-- Do not copy MeasurementUnitRef - it has been removed -->
			<xsl:when test="name()='MeasurementUnitRef'"/>
			<!-- Do not copy Presentation - it has been removed -->
			<xsl:when test="name()='Presentation'"/>
			<!-- Other cases -->
			<xsl:otherwise>
				<!-- create the element in the ODMv2 namespace -->
				<xsl:element name="{local-name()}" namespace="{$ODMv2NS}">
					<!-- copy the attributes -->
					<xsl:for-each select="@*"><xsl:copy-of select="."/></xsl:for-each>
					<!-- NEW for TranslatedText: we need an additional attribute "type" with value "text/plain" -->
					<xsl:if test="name()='TranslatedText'">
						<xsl:attribute name="type">text/plain</xsl:attribute>
					</xsl:if>
					<!-- make a deep copy of the child elements in the new namespace
						(uses recursion) -->
					<xsl:for-each select="./*">
						<xsl:call-template name="makedeepcopy_to_ODMv2"/>
					</xsl:for-each>
					<!-- copy any text content -->
					<xsl:copy-of select="./text()"/>
				</xsl:element>
			</xsl:otherwise>
		</xsl:choose>
		
	</xsl:template>
	
	<!-- we start from "MetaDataVersion" -->
	<xsl:template name="odm:MetaDataVersion">
		<xsl:element name="MetaDataVersion" namespace="{$ODMv2NS}">
			<!-- Copy the attributes except for "Description" -->
			<xsl:for-each select="@*[not(name()='Description')]"><xsl:copy-of select="."/></xsl:for-each>
			<!-- The "Description" is moved from an attribute to a child element -->
			<xsl:if test="@Description">
				<xsl:element name="Description" namespace="{$ODMv2NS}">
					<xsl:element name="TranslatedText" namespace="{$ODMv2NS}">
						<xsl:attribute name="type">text/plain</xsl:attribute>
						<xsl:value-of select="@Description"/>
					</xsl:element>
				</xsl:element>
			</xsl:if>
			<!-- get the Protocol element containing StudyEventRef elements -->
			<!-- Make a temporary structure of StudyEvents of type 'Scheduled' -->
			<xsl:variable name="scheduledstudyevents">
				<xsl:for-each select="odm:Protocol/odm:StudyEventRef">
					<!-- get the OID -->
					<xsl:variable name="studyeventoid" select="@StudyEventOID"/>
					<!-- get the corresponding StudyEventDef, and only include when @Type='scheduled' -->
					<xsl:variable name="studyeventelement" select="../../odm:StudyEventDef[@OID=$studyeventoid]"/>
					<xsl:variable name="studyeventdeftype" select="$studyeventelement/@Type"/>
					<!--xsl:message>studyeventdeftype = <xsl:value-of select="$studyeventdeftype"/></xsl:message-->
					<!-- copy StudyEventRef and StudyEventDef into the temporary structure, 
						so that we keep the order of the one in 'Protocol' -->
					<xsl:if test="$studyeventdeftype = 'Scheduled'">
						<xsl:copy-of select="."/>
						<xsl:copy-of select="$studyeventelement"/>
					</xsl:if>
				</xsl:for-each>
			</xsl:variable>
			<xsl:if test="odm:Protocol/odm:StudyEventRef"><!-- only make a workflow when StudyEvents are referenced -->
				<!-- create a Workflow element -->
				<xsl:element name="WorkflowDef" namespace="{$ODMv2NS}">
					<xsl:attribute name="OID">WF.MAIN</xsl:attribute>
					<xsl:attribute name="Name">Protocol main workflow</xsl:attribute>
					<!-- give it a description -->
					<xsl:element name="Description" namespace="{$ODMv2NS}">
						<xsl:element name="TranslatedText" namespace="{$ODMv2NS}">
							<xsl:attribute name="type">text/plain</xsl:attribute>
							<xsl:attribute name="xml:lang">en</xsl:attribute>
							<xsl:text>Linear workflow generated from ODM 1.3 'Protocol' element for 'Scheduled' StudyEvents</xsl:text>
						</xsl:element>
					</xsl:element>
					<!-- StudyStart element -->
					<xsl:for-each select="$scheduledstudyevents/odm:StudyEventRef">
						<!-- first and last go into "WorkflowStart" and "WorkflowEnd" -->
						<!-- First StudyEvent -->
						<xsl:choose>
							<xsl:when test="position()=1">
								<xsl:element name="WorkflowStart" namespace="{$ODMv2NS}">
									<xsl:attribute name="StartOID"><xsl:value-of select="@StudyEventOID"/></xsl:attribute>
								</xsl:element>
							</xsl:when>
							<!-- last StudyEvent -->
							<xsl:when test="position()=count(../odm:StudyEventRef)">
								<!-- do this later, after all transitions -->
							</xsl:when>
							<!-- all other studyEvents, just generate transitions from and to them (linear workflow) -->
							<xsl:otherwise>
								<xsl:element name="Transition" namespace="{$ODMv2NS}">
									<!-- get the OID and Name of the StudyEvent just before the current one -->
									<xsl:variable name="priorstudyeventoid" select="preceding-sibling::odm:StudyEventRef[1]/@StudyEventOID"/>
									<xsl:variable name="priorstudyeventname" select="../odm:StudyEventDef[@OID=$priorstudyeventoid]/@Name"/>
									<!--xsl:message>priorstudyeventoid = <xsl:value-of select="$priorstudyeventoid"/></xsl:message-->
									<xsl:variable name="currentstudyeventoid" select="@StudyEventOID"/>
									<xsl:variable name="currentstudyeventname" select="../odm:StudyEventDef[@OID=$currentstudyeventoid]/@Name"/>
									<xsl:variable name="transitionoid" select="concat('TR.',$priorstudyeventoid,'.',$currentstudyeventoid)"/>
									<xsl:attribute name="OID"><xsl:value-of select="$transitionoid"/></xsl:attribute>
									<xsl:attribute name="Name"><xsl:value-of select="concat('Transition between StudyEvent ',$priorstudyeventname,' and StudyEvent ',$currentstudyeventname)"/></xsl:attribute>
									<!-- Source and Target -->
									<xsl:attribute name="SourceOID"><xsl:value-of select="$priorstudyeventoid"/></xsl:attribute>
									<xsl:attribute name="TargetOID"><xsl:value-of select="$currentstudyeventoid"/></xsl:attribute>
								</xsl:element>
							</xsl:otherwise>
						</xsl:choose>
					</xsl:for-each><!-- end of iteration over all StudyEventRef elements -->
					<!-- we still require the last transition -->
					<xsl:variable name="laststudyeventoid" select="$scheduledstudyevents/odm:StudyEventRef[last()]/@StudyEventOID"/>
					<xsl:variable name="laststudyeventname" select="$scheduledstudyevents/odm:StudyEventDef[@OID=$laststudyeventoid]/@Name"/>
					<xsl:variable name="secondlaststudyeventoid" select="$scheduledstudyevents/odm:StudyEventRef[last()-1]/@StudyEventOID"/>
					<xsl:variable name="secondlaststudyeventname" select="$scheduledstudyevents/odm:StudyEventDef[@OID=$secondlaststudyeventoid]/@Name"/>
					<xsl:variable name="transitionoid" select="concat('TR.',$secondlaststudyeventoid,'.',$laststudyeventoid)"/>
					<xsl:element name="Transition" namespace="{$ODMv2NS}">
						<xsl:attribute name="OID"><xsl:value-of select="$transitionoid"/></xsl:attribute>
						<xsl:attribute name="Name"><xsl:value-of select="concat('Transition between StudyEvent ',$secondlaststudyeventname,' and StudyEvent ',$laststudyeventname)"/></xsl:attribute>
						<xsl:attribute name="SourceOID"><xsl:value-of select="$secondlaststudyeventoid"/></xsl:attribute>
						<xsl:attribute name="TargetOID"><xsl:value-of select="$laststudyeventoid"/></xsl:attribute>
					</xsl:element>
					<!-- and the workflow end -->
					<xsl:element name="WorkflowEnd" namespace="{$ODMv2NS}">
						<xsl:attribute name="EndOID"><xsl:value-of select="$scheduledstudyevents/odm:StudyEventRef[last()]/@StudyEventOID"/></xsl:attribute>
					</xsl:element>
				</xsl:element><!-- End of WorkflowDef element -->
			</xsl:if>
			<!-- make deep copy in the ODMv2 namespace for all other elements -->
			<xsl:for-each select="odm:*[not(local-name()='Protocol')]">
				<xsl:call-template name="makedeepcopy_to_ODMv2"/>
			</xsl:for-each>
		</xsl:element>
	</xsl:template>
	
</xsl:stylesheet>