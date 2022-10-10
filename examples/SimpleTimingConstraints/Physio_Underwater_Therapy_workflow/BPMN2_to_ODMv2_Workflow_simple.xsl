<?xml version="1.0" encoding="UTF-8"?>

<xsl:stylesheet xmlns:xsl="http://www.w3.org/1999/XSL/Transform" xmlns:odm="http://www.cdisc.org/ns/odm/v2.0" xmlns:bpmn="http://www.omg.org/spec/BPMN/20100524/MODEL" version="2.0">
	<xsl:output method="xml" indent="yes"/>
	<!-- XSLT to transform BPMN2 into ODMv2 workflow using the XSLT BPMN2_to_ODMv2_Workflow_simple.xsl -->
	<xsl:template match="/">
		<xsl:comment>ODMv2 Workflow automatically created from a Workflow definition in BPMN2-XML format using the XSLT BPMN2_to_ODMv2_Workflow_simple.xsl</xsl:comment>
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="bpmn:definitions">
		<xsl:apply-templates/>
	</xsl:template>
	<xsl:template match="bpmn:process">
		<odm:MetaDataVersion OID="MV.001" Name="MetaDataVersion 1">
			<xsl:comment>We model all the tasks as StudyEvents</xsl:comment>
			<xsl:comment>For a repeating task, we would set @Repeating='Yes'</xsl:comment>
			
			<!-- Workflow part -->
			<xsl:element name="odm:WorkflowDef">
				<!-- Assign an OID - take it from the BPMN2 process-id prefixed by "WF." -->
				<xsl:attribute name="OID"><xsl:value-of select="concat('WF.',@id)"/></xsl:attribute>
				<!-- Assign a Name - simply take it from the BPMN2 process-id -->
				<xsl:attribute name="Name"><xsl:value-of select="@id"/></xsl:attribute>
				<xsl:if test="./bpmn:startEvent">
					<xsl:element name="odm:WorkflowStart">
						<xsl:attribute name="StartOID"><xsl:value-of select="./bpmn:startEvent/@id"/></xsl:attribute>
					</xsl:element>
				</xsl:if>
				<!-- First add the WorkflowStart -->
				<!-- we then need to define all the transitions - 
					in BPMN2, all transitions are defined twice or three times, once as "incoming" and once as "outgoing", 
					and an additional one as "sequenceFlow" -->
				<!-- we start with all "outgoing" transitions -->
				<!-- we do however want to exclude transitions from the start event and end event for now -->
				<xsl:for-each select="//bpmn:sequenceFlow">
					<!-- get the id -->
					<xsl:variable name="transitionid" select="@id"/>
					<xsl:variable name="sourceref" select="@sourceRef"/>
					<xsl:variable name="targetref" select="@targetRef"/>
					<!-- for the case the target is an intermediateCatchEvent -->
					<xsl:variable name="outgoing" select="//bpmn:intermediateCatchEvent[@id=$targetref]/bpmn:outgoing/text()"/>
					<xsl:variable name="targetTask" select="//bpmn:task[bpmn:incoming/text()=$outgoing]/@name"/>
					<!-- we need a "Name" but it will not always be present, 
							so if it isn't, we just list source and target name -->
					<xsl:variable name="transitionname">
						<xsl:choose>
							<xsl:when test="@name">
								<xsl:value-of select="@name"/>
							</xsl:when>
							<!-- TODO: in case of a timer in between, we do not want to have the name of the timer in the "to", 
								but we want to have the name of the subsequent task -->
							<xsl:when test="//bpmn:intermediateCatchEvent/@id = $targetref">Transition from <xsl:value-of select="//bpmn:outgoing[text()=$transitionid]/../@name"/> to <xsl:value-of select="$targetTask"/>
							</xsl:when>
							<!-- the normal case: use the names of source and target taskn -->
							<xsl:otherwise>Transition from <xsl:value-of select="//bpmn:outgoing[text()=$transitionid]/../@name"/> to <xsl:value-of select="//bpmn:incoming[text()=$transitionid]/../@name"/></xsl:otherwise>
						</xsl:choose>
					</xsl:variable>
					<!-- source and target id -->
					<xsl:variable name="sourceid">
						<xsl:value-of select="@sourceRef"/>
					</xsl:variable>
					<xsl:variable name="targetid">
						<xsl:value-of select="@targetRef"/>
					</xsl:variable>
					<!-- we (still) want to exclude start and end event transitions for the moment -->
					<!-- we also exclude catching events such as timers -->
					<!--xsl:if test="local-name(//*[@id=$sourceid])!='startEvent' and local-name(//*[@id=$targetid])!='endEvent' and local-name(//*[@id=$sourceid])!='intermediateCatchEvent'"-->
					<!-- 2020-03-31: do not exclude start and end event anymore-->
					<xsl:if test="local-name(//*[@id=$sourceid])!='intermediateCatchEvent'">
						<xsl:element name="odm:Transition">
							<xsl:attribute name="OID">
								<xsl:value-of select="concat('TR.',@id)"/>
							</xsl:attribute>
							<xsl:attribute name="Name">
								<xsl:value-of select="$transitionname"/>
							</xsl:attribute>
							<!-- what is the source? If it is a "Branching", we need to use "SourceBranchingOID", 
								otherwise it is SourceStudyEventOID -->
							<!--
							<xsl:choose>
								<xsl:when test="local-name(//*[@id=$sourceid])='exclusiveGateway' or local-name(//*[@id=$sourceid])='parallelGateway'">
									<xsl:attribute name="SourceBranchingOID"><xsl:value-of select="$sourceid"/></xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="SourceStudyEventOID"><xsl:value-of select="$sourceid"/></xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>  -->
							<!-- 2019-04-15: we ALWAYS use SourceOID, and make no distinction between what source it is -->
							<xsl:attribute name="SourceOID">
								<xsl:value-of select="$sourceid"/>
							</xsl:attribute>
							<!-- what is the target? If it is a "Branching", we need to use "TargetBranchingOID", 
								otherwise it is TargetStudyEventOID -->
							<!-- 2019-04-15: we ALWAYS use TargetOID, make no distinction between the type of target -->
							<xsl:choose>
								<xsl:when test="local-name(//*[@id=$targetid])='exclusiveGateway' or local-name(//*[@id=$targetid])='parallelGateway'">
									<xsl:attribute name="TargetOID">
										<xsl:value-of select="$targetid"/>
									</xsl:attribute>
								</xsl:when>
								<xsl:when test="local-name(//*[@id=$targetid])='intermediateCatchEvent'">
									<!-- the target is a timer event or another intermediate catch event, 
										we need to find the target that comes AFTER the timer -->
									<xsl:variable name="temp" select="//bpmn:intermediateCatchEvent[@id=$targetid]/bpmn:outgoing/text()"/>
									<xsl:variable name="followingtargettransitionoid" select="//bpmn:sequenceFlow[@id=$temp]/@targetRef"/>
									<xsl:attribute name="TargetOID">
										<xsl:value-of select="$followingtargettransitionoid"/>
									</xsl:attribute>
								</xsl:when>
								<xsl:otherwise>
									<xsl:attribute name="TargetOID">
										<xsl:value-of select="$targetid"/>
									</xsl:attribute>
								</xsl:otherwise>
							</xsl:choose>
						</xsl:element>
					</xsl:if>
				</xsl:for-each>
				<!-- Now add all the branches from "exclusiveGateway and parallelGateway -->
				<xsl:for-each select="bpmn:exclusiveGateway">
					<xsl:comment>Branching definition</xsl:comment>
					<xsl:element name="odm:Branching">
						<xsl:attribute name="OID">
							<xsl:value-of select="@id"/>
						</xsl:attribute>
						<xsl:attribute name="Name">
							<xsl:value-of select="@name"/>
						</xsl:attribute>
						<xsl:attribute name="Type">Exclusive</xsl:attribute>
						<!-- add the outgoing transitions -->
						<xsl:for-each select="bpmn:outgoing">
							<xsl:element name="odm:TargetTransition">
								<xsl:variable name="oid" select="concat('TR.',.)"/>
								<xsl:variable name="conditionoid" select="concat('COND.',.)"/>
								<xsl:attribute name="TargetTransitionOID">
									<xsl:value-of select="$oid"/>
								</xsl:attribute>
								<xsl:attribute name="ConditionOID">
									<xsl:value-of select="$conditionoid"/>
								</xsl:attribute>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:for-each>
				<xsl:for-each select="bpmn:parallelGateway">
					<xsl:element name="odm:Branching">
						<xsl:attribute name="OID">
							<xsl:value-of select="@id"/>
						</xsl:attribute>
						<xsl:attribute name="Name">
							<xsl:value-of select="@name"/>
						</xsl:attribute>
						<xsl:attribute name="Type">Parallel</xsl:attribute>
						<!-- add the outgoing transitions -->
						<xsl:for-each select="bpmn:outgoing">
							<xsl:comment>Remark that there is no Condition reference for parallel execution</xsl:comment>
							<xsl:element name="odm:TargetTransition">
								<xsl:variable name="oid" select="concat('TR.',.)"/>
								<xsl:variable name="conditionoid" select="concat('COND.',.)"/>
								<xsl:attribute name="TargetTransitionOID">
									<xsl:value-of select="$oid"/>
								</xsl:attribute>
							</xsl:element>
						</xsl:for-each>
					</xsl:element>
				</xsl:for-each>
				<xsl:if test="./bpmn:endEvent">
					<xsl:element name="odm:WorkflowEnd">
						<xsl:attribute name="EndOID"><xsl:value-of select="./bpmn:endEvent/@id"/></xsl:attribute>
					</xsl:element>
				</xsl:if>
			</xsl:element>
			<!-- StudyEventDef part - needs to come AFTER WorkflowDef-->
			<!-- 2020-03-31: adding start- and end as StudyEvents -->
			<xsl:for-each select="./bpmn:startEvent">
				<xsl:element name="odm:StudyEventDef" namespace="http://www.cdisc.org/ns/odm/v2.0">
					<xsl:attribute name="OID">
						<xsl:value-of select="@id"/>
					</xsl:attribute>
					<xsl:attribute name="Name">
						<xsl:value-of select="@name"/>
					</xsl:attribute>
					<xsl:attribute name="Type">Scheduled</xsl:attribute>
					<xsl:attribute name="Repeating">No</xsl:attribute>
				</xsl:element>
			</xsl:for-each>
			<!-- all other tasks -->
			<xsl:for-each select="bpmn:task">
				<xsl:element name="odm:StudyEventDef" namespace="http://www.cdisc.org/ns/odm/v2.0">
					<xsl:attribute name="OID">
						<xsl:value-of select="@id"/>
					</xsl:attribute>
					<xsl:attribute name="Name">
						<xsl:value-of select="@name"/>
					</xsl:attribute>
					<xsl:attribute name="Type">Scheduled</xsl:attribute>
					<xsl:attribute name="Repeating">No</xsl:attribute>
				</xsl:element>
			</xsl:for-each>
			<!-- End Event -->
			<xsl:for-each select="./bpmn:endEvent">
				<xsl:element name="odm:StudyEventDef" namespace="http://www.cdisc.org/ns/odm/v2.0">
					<xsl:attribute name="OID">
						<xsl:value-of select="@id"/>
					</xsl:attribute>
					<xsl:attribute name="Name">
						<xsl:value-of select="@name"/>
					</xsl:attribute>
					<xsl:attribute name="Type">Scheduled</xsl:attribute>
					<xsl:attribute name="Repeating">No</xsl:attribute>
				</xsl:element>
			</xsl:for-each>
			<!-- End of Workflow element -->
			<!-- 2019-03-29: Relative timings -->
			<xsl:if test="count(//bpmn:intermediateCatchEvent/bpmn:timerEventDefinition) gt 0">
				<xsl:comment>Timings</xsl:comment>
				<xsl:element name="odm:Timing">
					<xsl:for-each select="//bpmn:intermediateCatchEvent/bpmn:timerEventDefinition">
						<xsl:comment>Relative timing</xsl:comment>
						<!-- possibility 1: we define the timer on the transition itself -->
						<xsl:comment>possibility 1: we define the timer on the transition itself</xsl:comment>
						<xsl:element name="TransitionTimingConstraínt">
							<xsl:attribute name="OID">
								<xsl:value-of select="concat('TIM.',@id)"/>
							</xsl:attribute>
							<xsl:attribute name="Name">Relative timing constraint for:</xsl:attribute>
							<!-- we take incoming flowSequence, as we did for defining the transition itself -->
							<xsl:attribute name="TransitionDestinationOID">
								<xsl:value-of select="concat('TR.',../bpmn:incoming/text())"/>
							</xsl:attribute>
							<xsl:attribute name="TimepointRelativeTarget">
								<xsl:value-of select="bpmn:timeDuration/text()"/>
							</xsl:attribute>
						</xsl:element>
						<!-- possibility 2: we define the timer by the source and target Study- or other events -->
						<xsl:comment>possibility 2: we define the timer by the source and target Study- or other events</xsl:comment>
						<xsl:element name="RelativeTimingConstraínt">
							<xsl:attribute name="OID">
								<xsl:value-of select="concat('TIM.',@id)"/>
							</xsl:attribute>
							<xsl:attribute name="Name">Relative timing constraint for:</xsl:attribute>
							<!-- source and target flows -->
							<xsl:variable name="sourceSequenceFlow" select="../bpmn:incoming/text()"/>
							<xsl:variable name="targetSequenceFlow" select="../bpmn:outgoing/text()"/>
							<!-- and from these, get the source and target activities -->
							<xsl:variable name="sourceTask" select="//bpmn:task[bpmn:outgoing/text()=$sourceSequenceFlow]/@id"/>
							<xsl:variable name="targetTask" select="//bpmn:task[bpmn:incoming/text()=$targetSequenceFlow]/@id"/>
							<xsl:attribute name="SourceStudyEventOID">
								<xsl:value-of select="$sourceTask"/>
							</xsl:attribute>
							<xsl:attribute name="TargetStudyEventOID">
								<xsl:value-of select="$targetTask"/>
							</xsl:attribute>
							<xsl:attribute name="TimepointRelativeTarget">
								<xsl:value-of select="bpmn:timeDuration/text()"/>
							</xsl:attribute>
						</xsl:element>
					</xsl:for-each>
				</xsl:element>
			</xsl:if>
			<!-- ConditionDef elements from the branching-->
			<xsl:for-each select="bpmn:exclusiveGateway/bpmn:outgoing">
				<xsl:variable name="flowid" select="text()"/>
				<xsl:comment>Important: Note that BPMN2 does not have a mechanism to describe the condition in a machine-readable way</xsl:comment>
				<xsl:element name="odm:ConditionDef">
					<xsl:attribute name="OID">
						<xsl:value-of select="concat('COND.',$flowid)"/>
					</xsl:attribute>
					<xsl:attribute name="Name">Condition for <xsl:value-of select="//bpmn:sequenceFlow[@id=$flowid]/@name"/></xsl:attribute>
					<xsl:element name="odm:Description">
						<xsl:element name="odm:TranslatedText">
							<xsl:attribute name="type">text/plain</xsl:attribute>
							<xsl:text>Condition for </xsl:text><xsl:value-of select="//bpmn:sequenceFlow[@id=$flowid]/@name"/>
						</xsl:element>
					</xsl:element>
					<!-- MethodSignature is required in ODMv2 but can be empty -->
					<xsl:element name="odm:MethodSignature"></xsl:element>
				</xsl:element>
			</xsl:for-each>
		</odm:MetaDataVersion>
	</xsl:template>
</xsl:stylesheet>