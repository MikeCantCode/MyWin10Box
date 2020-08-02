# Resolve-DscResource.ps1
# This script will take a list of DSC Resources and Install them.
# If no PowerShell DataFile or DscResource is provided as a parameter, it will look for a PowerShell Data File here: "$PSScriptRoot\Resolve-DscResource.psd1"

[CmdletBinding()]
param (
    [Parameter(Mandatory,ParameterSetName = 'DataFile')]
    [string]
    $DataFile,

    [Parameter(Mandatory,ParameterSetName = 'DscResource')]
    [string[]]
    $DscResource,

    [switch]
    $Force

)

if ($PSBoundParameters.ContainsKey('DataFile')) {
    $DscResourcesDataFile = Import-PowerShellDataFile -Path $DataFile
    $DscResources = $DscResourcesDataFile.DscResources
}
elseif ($PSBoundParameters.ContainsKey('DscResource')) {
    $DscResources = $DscResource
}
else {
    $DscResourcesDataFile = Import-PowerShellDataFile -Path "$PSScriptRoot\Resolve-DscResource.psd1"
    $DscResources = $DscResourcesDataFile.DscResources
}

Write-Verbose -Message "Testing for NuGet..."
$MinNugetVersion = 2.8.5.201
$NuGet = Get-PackageProvider -Name NuGet
if ($NuGet.Version -lt $MinNugetVersion) {
    Write-Verbose -Message "NuGet is missing or below minimum version [$MinNugetVersion]. Installing now..."
    Install-PackageProvider -Name NuGet -MinimumVersion $MinNugetVersion -Force
    $NuGet = Get-PackageProvider -Name NuGet
}
Write-Verbose -Message "Installed Nuget Version: [$($Nuget.Version)]"


Write-Host "Installing DSC Resources..."
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

