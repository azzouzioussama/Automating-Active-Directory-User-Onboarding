# Documentation: Active Directory User Onboarding Automation

**Author:** Senior System Administrator (Gemini) / Oussama Azzouz  
**Purpose:** Automating new user creation in a Windows Server Lab environment using PowerShell.  
**Environment:** Windows Server 2022 (Virtual Machine), MYLAB.local domain.

## 1. Project Overview

The goal was to move away from manual user creation in "Active Directory Users and Computers" (ADUC) and use a PowerShell script to:

- Prompt for user details
- Standardize naming conventions (flastname)
- Automatically place users in the correct Organizational Unit (OU)
- Assign security group memberships based on department
- Set security defaults (Temporary password + Force change at login)

## 2. Environment Prerequisites

Before the script could run successfully, the following infrastructure was required:

**Infrastructure**
- Domain Controller: A Windows Server VM promoted to a Domain Controller
- Domain Name: MYLAB.local
- Distinguished Name (DN): DC=MYLAB,DC=local

**Active Directory Structure**

The following objects had to be created manually in ADUC to prevent "Object Not Found" errors:
- OUs: IT_Department, Sales
- Security Groups: Global_Users, GS_IT_Users, GS_Sales_Users

## 3. Technical Challenges & Resolutions

| Challenge | Cause | Resolution |
|-----------|-------|-----------|
| Execution Policy Error | Windows blocks scripts by default for security | Ran `Set-ExecutionPolicy RemoteSigned -Scope CurrentUser` |
| Command Not Recognized | RSAT (Remote Server Admin Tools) were not installed | Installed the Active Directory module for PowerShell |
| Unwilling to Process Request | Target path (OU) or Domain Name was incorrect | Updated script to use `DC=MYLAB,DC=local` and matched OU names exactly |
| Syntax Error (Unexpected Token) | An extra closing brace `}` ended the script logic early | Removed redundant brace and verified code blocks |
| VM Isolation | VirtualBox blocked Drag & Drop/Clipboard | Installed Guest Additions and set Drag & Drop to "Bidirectional" |

## 4. Final PowerShell Script Logic

The final script is divided into functional blocks:

- **Input:** Uses `Read-Host` to gather First Name, Last Name, and Department
- **String Manipulation:** Uses `.Substring(0,1)` and `.ToLower()` to format the username
- **Switch Logic:** Maps "Department" input to a specific AD Path (Distinguished Name)
- **Splatting:** Uses a Hashtable (`@UserParams`) to organize user data cleanly
- **Error Handling:** Uses Try/Catch blocks to capture and report server errors without crashing

## 5. How to Run the Script

1. Open PowerShell as an Administrator
2. Navigate to the script location (Desktop)
3. Run the script using the `-Verbose` switch for detailed logging:
    ```powershell
    .\NewUser.ps1 -Verbose
    ```
4. Follow the prompts to enter user information

## 6. Pro-Tips for Junior Admins

- **Always check the Path:** Most AD script errors are caused by a single typo in the Distinguished Name (DN)
- **Use the Attribute Editor:** If unsure of an OU's path, right-click the OU in ADUC > Properties > Attribute Editor > distinguishedName
- **The "Test" User:** Always keep a "dummy" department in your script logic for testing purposes