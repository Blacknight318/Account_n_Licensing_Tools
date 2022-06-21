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
    }
}


# This is to make things easier to search AzureAD for Status and emailID
function Search-AzureAD{
    param(
        
    )

}

#Main code below
Initialize-AzureAD

