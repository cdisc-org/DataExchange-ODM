#### ODM XML v2 Examples

This folder contains examples to demonstrate capabilities of ODM v2.

* ##### [Atlas_RS](./Atlas_RS/README.md)

  Example for the ATLAS questionnaire.

* ##### [Chronic Low Back Pain](./Chronic_Low_Back_Pain/README.md)

  Example for "Chronic Back Pain".

* ##### [Columbia Suicidal Scale](./Columbia_Suicidal_Scale/README.md)

  Example for the Columbia-Suicide Severity Rating Scale" (C-SSRS)" questionnaire.
  The example uses "matrix" style questions and repeating ItemGroups, and  "WorkflowDef" element to describe the workflow within the questionnaire (we will NOT use  "CollectionExceptionConditionOID" for skip questions where possible)

* ##### [Conditional Repeats](./Conditional_Repeats/README.md)

  Simple example of a workflow with a loop.

* ##### [Crossover Studydesign](./Crossover_Studydesign/README.md)

  Example of a cross-over study design with epochs, arms and cells.

* ##### [Data Collection](./Data-Collection/README.md)

  Medical History example form with a set of questions that repeat for each of a number of pre-defined histories, and allows additional histories to be collected. One entry in the repeating codelist represents an "other" body system, and for these repeats an additional field collects the "other" information.

* ##### [Demographics RACE](./Demographics_RACE/README.md)

  Simple Demographics CRF example with "check all that apply" for RACE, and with a "Race Other" field.

* ##### [FHIR](./FHIR/README.md)

  Example showing the use of Electronic Health Records (EHRs) in HL7-FHIR format to retrieve information and populate an e-CRF.

* ##### [FHIR Integration](./FHIR_Integration/README.md)

  Example demonstrating the use of the FHIR API to extract information from an EHR.

* ##### [Inclusion Exclusion Criteria Workflow](./Inclusion_Exclusion_Criteria_Workflow/README.md)

  Example to demonstrate Inclusion and Exclusion criteria generated as a workflow.

* ##### [Matrix CRF from TAUG Dyslipidemia 1.0](./Matrix_CRF_From_TAUG_Dyslipidemia_1_0/README.md)

  ODM implementation of the "Hypercholesterolemia/Cardiovascular Risk Factors Family History" form.

* ##### [Physio Underwater Therapy Workflow](./Physio_Underwater_Therapy_workflow/README.md)

  Example to demonstrate the transformation from BPMN2-XML to CDISC-ODMv2 "Workflow".

* ##### [Protocol to Workflow](./Protocol_to_Workflow/README.md)

  XSLT stylesheet that demonstrates the transformation of an ODM v.1.3.x study design into an ODM v.2 study design, in which a workflow ("WorkflowDef" element) for all "scheduled" StudyEvents is generated.

* ##### [Repeating ItemGroup CDASH 1.1 Stroke Lung Disease IBD Cancer History CRF](./Repeating_ItemGroup_CDASH_1-1_Stroke_LungDisease_IBD_CancerHistory_CRF/README.md)

  This example to showcase the use of "repeating" groups, with the complication that for each of these, their different values apply for "type" depending on the item, and each of them has an "other" field.

* ##### [Simple Timing Constraints](./SimpleTimingConstraints/README.md)

  Example to demonstrate timing constraints in a workflow.

* ##### [Timing LZZT](./Timing_LZZT/README.md)

  Example of development of a workflow for the LZZT trial.
