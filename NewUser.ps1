<#
.SYNOPSIS
    Automates the creation of a new Active Directory user.
#>

[CmdletBinding()]
param()

Process {
    Write-Verbose "--- Starting User Onboarding Process ---"

    # 1. Gather User Information
    $FirstName = Read-Host "Enter First Name"
    $LastName  = Read-Host "Enter Last Name"
    $Dept      = Read-Host "Enter Department (e.g., Sales, HR, IT, Finance)"

    # 2. Generate Username
    $Username = ($FirstName.Substring(0,1) + $LastName).ToLower()
    $DisplayName = "$FirstName $LastName"
    $UserPrincipalName = "$Username@MYLAB.local" 

    Write-Verbose "Target Username: $Username"

    # 3. Define Logic for OUs and Groups
    switch ($Dept) {
        "Sales" {
            $TargetOU = "OU=Sales,DC=MYLAB,DC=local" 
            $DeptGroup = "GS_Sales_Users"
        }
        "IT" {
            $TargetOU = "OU=IT_Department,DC=MYLAB,DC=local"
            $DeptGroup = "GS_IT_Users"
        }
        Default {
            Write-Warning "Department not recognized. Defaulting to Users container."
            $TargetOU = "CN=Users,DC=MYLAB,DC=local"
            $DeptGroup = $null
        }
    } # Only ONE brace here!

    # 4. Check if User Already Exists
    Write-Verbose "Checking if user $Username already exists in AD..."
    if (Get-ADUser -Filter "SamAccountName -eq '$Username'") {
        Write-Error "User '$Username' already exists! Aborting script."
        return
    }

    # 5. Security Setup
    $TempPassword = ConvertTo-SecureString "TempPass123!" -AsPlainText -Force
    $GlobalGroup = "Global_Users"

    # 6. Create the User (Try/Catch Block)
    try {
        Write-Verbose "Creating user account in $TargetOU..."
        
        $UserParams = @{
            Name                  = $DisplayName
            GivenName             = $FirstName
            Surname               = $LastName
            SamAccountName        = $Username
            UserPrincipalName     = $UserPrincipalName
            Path                  = $TargetOU
            AccountPassword       = $TempPassword
            ChangePasswordAtLogon = $true
            Enabled               = $true
            Description           = "Onboarded via Automation Script on $(Get-Date)"
            Department            = $Dept
        }

        New-ADUser @UserParams
        Write-Host "SUCCESS: User account for $DisplayName created." -ForegroundColor Green

        # 7. Assign Groups
        Write-Verbose "Adding user to $GlobalGroup..."
        Add-ADGroupMember -Identity $GlobalGroup -Members $Username

        if ($DeptGroup) {
            Write-Verbose "Adding user to department group: $DeptGroup..."
            Add-ADGroupMember -Identity $DeptGroup -Members $Username
        }

        Write-Host "Onboarding complete for $Username." -ForegroundColor Cyan
    }
    catch {
        Write-Error "An error occurred during account creation: $($_.Exception.Message)"
    }
}