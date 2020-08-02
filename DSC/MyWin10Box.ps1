Configuration MyWin10Box {
    param (

    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration
    Import-DscResource -Module ComputerManagementDsc
    Import-DscResource -ModuleName cChoco
    Import-DscResource -ModuleName VMware.vSphereDSC

    Node $AllNodes.NodeName {

        Computer $Node.NodeName {
            Name = $Node.NodeName
        }

        PendingReboot AfterComputerNameChange {
            Name      = 'AfterComputerNameChange'
            DependsOn = "[Computer]$($Node.NodeName)"
        }

        cChocoInstaller installChoco {
            InstallDir = "C:\choco"
        }

        $ChocoPackages = $Node.ChocoPackages
        foreach ($ChocoPackage in $ChocoPackages) {
            cChocoPackageInstaller $ChocoPackage {
                Name        = $ChocoPackage
                DependsOn   = "[cChocoInstaller]installChoco"
                #This will automatically try to upgrade if available, only if a version is not explicitly specified.
                AutoUpgrade = $True
            }
        }
    }

    Node $AllNodes.Where{ $_.Role -eq "MyWin10Box" }.NodeName {

        PowerCLISettings PowerCLISettings {
            SettingsScope = 'LCM'
            ParticipateInCeip = $false
            InvalidCertificateAction = 'Ignore'
        }

    }

}

# Compile Configuration
MyWin10Box -ConfigurationData "$PSScriptRoot\MyWin10Box.psd1" -OutputPath C:\
Remove-Item -Path C:\localhost.mof -Force -ErrorAction 'SilentlyContinue'
Rename-Item -Path C:\MyWin10Box.mof -NewName localhost.mof -Force
Set-NetConnectionProfile -NetworkCategory Private
Set-Item -Path WSMan:\localhost\MaxEnvelopeSizeKb -Value 153600
