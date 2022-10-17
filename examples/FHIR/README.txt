An example showing the use of Electronic Health Records (EHRs) in HL7-FHIR format to retrieve information and populate an e-CRF.
The "Origin" element under "ItemGroupDef" shows which FHIR resources are used to populate the CRF,
whereas the "FormalExpression/Code" in the "MethodDef" element, for the white blood count (LOINC code 26464-8), 
shows the Python code to execute the retrieval.