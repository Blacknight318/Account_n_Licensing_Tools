<#
This script should automate the tasks of checking for a valid user account on AzureAD and call the scripts to check
user accounts on Adobe with the help of Opensource Python scripts suggested by Adobe.
Modules will the be build for assigning licenses based on userID's or email addresses(depending on the class)
#>

#Now for the imports
function Initialize-AzureAD {
    param (
    )
    try {
        Write-Progress -Activity "Initializing AzureAD" -Status "Checking for AzureAD Module..." -PercentComplete 0
        Get-InstalledModule -Name AzureAD -ErrorAction SilentlyContinue | Out-Null
        Write-Progress -Activity "Initializing AzureAD" -Status "Found AzureAD Module..." -PercentComplete 33
    }
    catch{
        Write-Progress -Activity "Initializing AzureAD" -Status "Attempting to install AzureAD Module..." -PercentComplete 0
        try {
            Install-Module -Name AzureAD -ErrorAction Stop
            Write-Progress -Activity "Initializing AzureAD" -Status "AzureAD Module sucessfull installed..." -PercentComplete 33
        }
        catch {
            Write-Error -Message "Failed to install AzureAD Module, check internet connection!!!"
            exit 1
        }
    }
    try {
        Write-Progress -Activity "Initializing AzureAD" -Status "Attempting to import AzureAD Module..." -PercentComplete 33
        Import-Module AzureAD -ErrorAction Stop
        Write-Progress -Activity "AzureAD Initialization in progress" -Status "Import of AzureAD Module Successfull: " -PercentComplete 66
        Write-Progress -Activity "Initializing AzureAD" -Status "Attempting to connect to AzureAD..." -PercentComplete 66
        Connect-AzureAD -ErrorAction Stop | Out-Null
        Write-Progress -Activity "Initializing AzureAD" -Status "Connection to AzureAD successfull" -PercentComplete 100
    }
    catch {
        Write-Error -Message "Failed to connect to AzureAD, check credentials and re-run script!"
        exit 1
    }
}


# This is to make things easier to search AzureAD for Status and emailID
function Find-AzureADMisfits{
    param(

    )
    # Starting with a full user list in memory to allow multiple searches without going back to the well
    Write-Progress -Activity "Retrieving full list of users from AzureAD"
    $full_user_list = Get-AzureADUser -All $true
    $counter = 0
    ForEach ($user in $full_user_list) {
        $counter++
        Write-Progress -Activity "Searching AzureAD for orphan accounts" -CurrentOperation $user.UserPrincipalName -PercentComplete (($counter / $full_user_list.count) * 100)
        if (($user.UserType -eq "Member") -and ($user.AccountEnabled -eq $true) -and ($user.UserPrincipalName -like "*onmicrosoft.com")){
            $writeItem = New-Object System.Object
                $writeItem | Add-Member NoteProperty -Name "UserPrincipalName" -Value $user.UserPrincipalName
                $writeItem | Add-Member NoteProperty -Name "UserType" -Value $user.UserType
                $writeItem | Add-Member NoteProperty "AccountEnabled" -Value $user.AccountEnabled
            Export-Csv -InputObject $writeItem -Append -Path misfit_users.csv
        }
    }
}
#Main code below
# REMINDER to add check for existing connection to AzureAD and bypass function
Initialize-AzureAD
Find-AzureADMisfits
Import-Csv -Path misfit_users.csv | Out-GridView

<# Unused commands
$active_info = Where-Object {$user.UserPrincipleName -like "*onmicrosoft.com" -and $user.UserType -eq "Member" -and $user.AccountEnabled -eq $true}
$the_misfits = Select-Object -InputObject $active_default_accounts  -Property UserPrincipaleName, GivenName, Department, LastDirSyncTime, Mail, MailNickName, SignInNames
Export-Csv -InputObject $the_misfits -Path misfits.csv
#>