@{
    AllNodes = @(
        @{
            NodeName                    = "*"
            PsDscAllowPlainTextPassword = $true
        }

        @{
            NodeName  = 'MyWin10Box'
            Role      = 'MyWin10Box'
            IPAddress = ''
            ChocoPackages = @(
                'git',
                'vscode',
                'chocolatey-vscode.extension',
                'firefox',
                'vmware-powercli-psmodule'
            )
        }
    )
}