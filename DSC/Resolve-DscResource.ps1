# Resolve-DscResource.ps1
# This script will take a list of DSC Resources and Install them.
# If no PowerShell DataFile or DscResource is provided as a parameter, it will look for a PowerShell Data File here: "$PSScriptRoot\Resolve-DscResource.psd1"

[CmdletBinding()]
param (
    $DataFile,
    [string[]]
    $DscResource,
    [switch]
    $Force
)

if ($DataFile -and $DscResource) {
    Write-Error -Message "You must only specify one parameter! Either '$DataFile' or '$DscResource'. Tip: You can specify multiple DSC Resources in the '$DscResource parameter."
}
elseif ($DataFile) {
    $DscResourcesDataFile = Import-PowerShellDataFile -Path $DataFile
    $DscResources = $DscResourcesDataFile.DscResources
}
elseif ($DscResource) {
    $DscResources = $DscResource
}
else {
    $DscResourcesDataFile = Import-PowerShellDataFile -Path "$PSScriptRoot\Resolve-DscResource.psd1"
    $DscResources = $DscResourcesDataFile.DscResources
}

Install-PackageProvider -Name NuGet -MinimumVersion 2.8.5.201 -Force

Write-Host "Installing DSC Resources"
foreach ($DscResource in $DscResources) {
    $Module = Get-Module -Name $DscResource -ListAvailable
    if (-not($Module)) {
        Write-Verbose -Message "Module [$DscResource] is missing. Installing now..." -Verbose
        Install-Module -Name $DscResource -Force
        $Module = Get-Module -Name $DscResource -ListAvailable
        if ($Module) {
            Write-Verbose -Message "SUCCESS: Module [$Module] Installed" -Verbose
        }
        else {
            Write-Verbose -Message "FAILURE: Module [$DscResource] NOT Installed" -Verbose
        }
    }
    else {
        Write-Verbose -Message "Module [$DscResource] is already installed." -Verbose
    }
}

