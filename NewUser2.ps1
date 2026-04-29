<#
.SYNOPSIS
    Creates a new Active Directory user and logs the action to a CSV.

.DESCRIPTION
    This function automates the onboarding process for MYLAB.local. It generates a username, 
    places the user in the correct OU based on department, assigns security groups, 
    and maintains an audit log in C:\Logs\OnboardingLog.csv.

.EXAMPLE
    New-CorporateUser -FirstName "Jane" -LastName "Doe" -Department "IT"
    Creates a user 'jdoe' in the IT_Department OU and logs it to CSV.
#>

function New-CorporateUser {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory=$true)]
        [string]$FirstName,

        [Parameter(Mandatory=$true)]
        [string]$LastName,

        [Parameter(Mandatory=$true)]
        [ValidateSet("IT", "Sales", "HR", "Finance")]
        [string]$Department
    )

    Process {
        Write-Verbose "--- Starting Professional Onboarding for $FirstName $LastName ---"

        # 1. Formatting
        $Username = ($FirstName.Substring(0,1) + $LastName).ToLower()
        $UserPrincipalName = "$Username@MYLAB.local"
        $LogPath = "C:\Logs\UserAudit.csv"

        # 2. OU and Group Logic
        switch ($Department) {
            "Sales" {
                $TargetOU = "OU=Sales,DC=MYLAB,DC=local"
                $DeptGroup = "GS_Sales_Users"
            }
            "IT" {
                $TargetOU = "OU=IT_Department,DC=MYLAB,DC=local"
                $DeptGroup = "GS_IT_Users"
            }
            Default {
                $TargetOU = "CN=Users,DC=MYLAB,DC=local"
                $DeptGroup = $null
            }
        }

        # 3. Create User
        try {
            $Password = ConvertTo-SecureString "TempPass123!" -AsPlainText -Force
            
            $UserParams = @{
                Name                  = "$FirstName $LastName"
                SamAccountName        = $Username
                UserPrincipalName     = $UserPrincipalName
                Path                  = $TargetOU
                AccountPassword       = $Password
                ChangePasswordAtLogon = $true
                Enabled               = $true
                Department            = $Department
            }

            New-ADUser @UserParams
            Write-Host "SUCCESS: Created $Username" -ForegroundColor Green

            # 4. Group Assignment
            Add-ADGroupMember -Identity "Global_Users" -Members $Username
            if ($DeptGroup) { Add-ADGroupMember -Identity $DeptGroup -Members $Username }

            # 5. CSV AUDIT LOG (The Digital Paper Trail)
            $LogEntry = [PSCustomObject]@{
                Date       = Get-Date -Format "yyyy-MM-dd HH:mm"
                User       = $Username
                Department = $Department
                CreatedBy  = $env:USERNAME
                Status     = "Success"
            }

            # Create the folder if it doesn't exist
            if (!(Test-Path "C:\Logs")) { New-Item -Path "C:\Logs" -ItemType Directory }
            
            $LogEntry | Export-Csv -Path $LogPath -Append -NoTypeInformation
            Write-Verbose "Audit log updated at $LogPath"

        }
        catch {
            Write-Error "Critical Failure: $($_.Exception.Message)"
        }
    }
}