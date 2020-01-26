# PS Import Policy - Features

<a name="documenttitle"></a>

![ZOBEC Consulting logo](img\zobec-consulting-red-full-96x96.png "ZOBEC Consulting logo")

Copyright &copy; 2019-2020 ZOBEC Consulting. All Rights Reserved.

## List of features

* Verify if LGPO (Local Group Policy Object Utility) Tool executable present. LGPO is required.
* Verify of supported version of LGPO Tool executable.
* Verify if policy files exist.
* Import of Local Group Policy file to running system.
* Internal type of Policy: InternalComputer/InternalUser/InternalAudit/InternalSecurity/Native
  * Computer policy from registry.pol file.
  * User policy from registry.pol file.
  * Audit policy configuration from audit.csv file.
  * Security policy configuration from GptTmpl.inf file.
  * Common directory with multiple policy objects (Native format of policy).
* Verification of imported policy in running system for registry based policy (Computer, or User only Policy).
* Automated run of tool with logging to text file.

[*Back to top*](#documenttitle "Top of the document")

## Documentation (all documents)

* [Documentation (ReadMe)](ReadMe.md).
* [Features](Features.md).
* [Release Notes (WhatsNew)](WhatsNew.md).
* [To Do Plan](ToDo.md).
* [License](License.md).
* [Security](Security.md).

[*Back to top*](#documenttitle "Top of the document")
