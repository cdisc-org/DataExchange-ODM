# ODM XML v2 Schema Naming Conventions

This document defines naming conventions for the ODM v2 XML schema. The names and case sensitivity of the XML elements, attributes and types from other standards used by ODM v2 are governed by their respective standards. For example, *complexType* is the name defined by XML Schema. The names from the vendor extensions are not governed by this. However, it is recommended that they follow this naming convention.

## Case Sensitivity

All names defined by ODM v2 are case sensitive.

## Element and Attribute Names

ODM v2 element and attribute names use Pascal case. Pascal case requires the first letter in the name and the first letter of each subsequent concatenated word to be capitalized, for example, *GlobalVariables*. There are some exceptions allowed in order to maintain backward compatibility, for example, *MetaDataVersion* element. Sometimes the names need to contain acronyms, for example *ODM* or *StudyOID*. Acronyms in the *ODM* element or attribute names are always written in upper case.

## Namespace prefix

The namespace prefixes are in lower case. The namespaces used in ODM v2 and their prefixes are shown in the following table:

| Namespace URI                                      | Prefix  |
|----------------------------------------------------|---------|
| [http://www.w3.org/2001/XMLSchema]                 | xs      |
| [http://www.w3.org/XML/1998/namespace]             | xml     |
| [http://www.cdisc.org/ns/odm/v2.0]                 | odm     |

[http://www.w3.org/2001/XMLSchema]: http://www.w3.org/2001/XMLSchema
[http://www.w3.org/XML/1998/namespace]: http://www.w3.org/XML/1998/namespace
[http://www.cdisc.org/ns/odm/v2.0]: http://www.cdisc.org/ns/odm/v2.0

## Type Name

Type names use Pascal case in most cases. Camel case is used to override the standard xml types and some types due to historical reasons such as *datetime* and *repeatKey*.
