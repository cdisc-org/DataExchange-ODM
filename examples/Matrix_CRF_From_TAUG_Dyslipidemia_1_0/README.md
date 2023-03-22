#### "Hypercholesterolemia/Cardiovascular Risk Factors Family History" Form Example

ODM implementation of the "Hypercholesterolemia/Cardiovascular Risk Factors Family History" form.
The form is in "matrix form" with the questions in the first column, with the other columns representing the family relationship types.
Each "cell" in the matrix has the choice between "Yes", "No", "Unknown" and "Not Applicable".

The file Hypercholesterolemia_CV_Risk_factors_FH_CRF_1_3_2.xml (ODM 1.3.2) shows how this can be realized using an ODM CodeList for defining the rows, i.e. the individual questions (ItemDef with OID=I.MHTERM and CodeList CL.MHTERM).
The columns are modelled as an ItemGroupDef (OID=IG.MH_TERM_FAMILY_RELATIONSHIP), containing references for each Item representing the family relationships, e.g. one for "biological father", one for "biological mmother", etc..

The file Hypercholesterolemia_CV_Risk_factors_FH_CRF_alternative_ValueLists.xml shows an alternative approach using ValueList-s, which is however more complicated.

The first approach is to be preferred.
