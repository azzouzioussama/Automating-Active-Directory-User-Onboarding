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

1. **Import the Tool**: Load the function into your current PowerShell session by "dot-sourcing" the script:
    ```powershell
    . .\NewUser.ps1
    ```

2. **Execute Provisioning**: Run the New-CorporateUser function with the required parameters:
    ```powershell
    New-CorporateUser -FirstName "Fred" -LastName "Kim" -Department "IT" -Verbose
    ```

3. **Verify Output**:
    - Check Active Directory Users and Computers to verify the user object exists in the correct OU.
    - Verify the entry in the audit log located at `C:\Logs\UserAudit.csv`.

## Security & Compliance

This automation framework adheres to modern security standards:

- **Password Policy**: All users are created with a secure temporary password via SecureString.
- **Credential Rotation**: The ChangePasswordAtLogon attribute is enforced (`$true`), ensuring compliance with NIST guidelines regarding user-owned credentials.
- **Principle of Least Privilege**: Users are automatically moved to department-specific security groups, ensuring they only have access to necessary resources.
- **Auditability**: The script logs the date, the target user, the department, and the ID of the administrator who performed the onboarding.

## Author

Oussama Azzouzi  
IT Support Specialist / System Administrator in Training