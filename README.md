# Enterprise IT Support: Automated User Provisioning

## Project Overview

In a modern enterprise environment, manual user onboarding is a high-latency process prone to human error and inconsistent data entry. This project provides a robust PowerShell automation framework to standardize the creation of Active Directory objects.

## Key Objectives

- **Operational Efficiency**: Reducing the time required to onboard new employees from minutes to seconds.
- **Data Integrity**: Enforcing strict naming conventions (e.g., flastname) and department-specific attributes.
- **Auditing**: Maintaining a transparent "paper trail" for every administrative action through automated CSV logging.
- **Standardization**: Ensuring every user is placed in the correct Organizational Unit (OU) and Security Group by default.

## Technical Stack

| Component | Specification |
|-----------|---------------|
| Operating System | Windows Server 2022 (Domain Controller) |
| Identity Service | Active Directory Domain Services (AD DS) |
| Scripting Language | PowerShell 5.1 with CmdletBinding |
| Logging Format | Flat-file CSV for Audit Compliance |

## Prerequisites

Before deploying this script, the following requirements must be satisfied:

- **RSAT Installation**: Remote Server Administration Tools (Active Directory module) must be enabled on the host machine.
- **Execution Policy**: The local system must be set to RemoteSigned or Bypass to allow script execution.
- **Administrative Rights**: The executing account must have delegated permissions to create objects in the target OUs.
- **Directory Structure**: OUs (e.g., IT_Department, Sales) and Security Groups (e.g., Global_Users) must exist in the directory before execution.

## Installation & Usage

A junior technician can execute the provisioning process by following these steps:

This project evolved from a standalone script to a professional PowerShell function. Depending on the version you are using, the execution method differs.

### Version 1: Legacy Script (NewUser.ps1)
1. Run the Script Directly

The original version is a straightforward script that prompts the user for information.

```powershell
.\NewUser.ps1
```

**Limitations**: No logging or modularity.


### Version 2: Professional Function (NewUser2.ps1)

The current version refactors the logic into a reusable function called New-CorporateUser. This version includes mandatory logging, parameter validation, and error handling.

1. Load the Function (Dot Sourcing)

Because this tool is built as a Function, it must be loaded into the PowerShell session memory before use. Note the space between the first dot and the file path:

```powershell
. C:\Users\Administrator\Desktop\HELPDESK\NewUser2.ps1
```

2. Execute Provisioning

Once loaded, call the custom command directly. You can use the Tab key to auto-complete the command name:

```powershell
New-CorporateUser -FirstName "Jane" -LastName "Doe" -Department "IT" -Verbose
```

3. Verification

- **ADUC**: Refresh the IT_Department OU to verify the new object.
- **Audit Logs**: Confirm the entry in `C:\Logs\UserAudit.csv`.


### Troubleshooting

| Issue | Cause | Solution |
|-------|-------|----------|
| Command not recognized | Script was run normally instead of "Dot Sourced." | Ensure you use the `. .\Script.ps1` format to load the function into scope. |
| Red Text / Security Error | Execution Policy is blocking scripts. | Run `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser`. |
| Server Unwilling to Process | The OU path or Domain Name is incorrect. | Verify that the TargetOU string matches your AD structure exactly. |

## Security & Compliance

- **Password Policy**: Enforces SecureString temporary passwords.
- **Credential Rotation**: Enforces ChangePasswordAtLogon for NIST compliance.
- **Auditability**: Logs administrative actions, timestamps, and technician IDs.


## Author

Oussama Azzouzi  
IT Support Specialist / System Administrator in Training