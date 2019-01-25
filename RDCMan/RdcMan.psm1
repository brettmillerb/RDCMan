$public = @(
    'Chocolatey\Find-ChocoPackage'
    'Chocolatey\Publish-ChocoPackage'
    'Chocolatey\Test-ChocoReplication'
    'Security\Get-Secure'
    'Security\New-Password'
    'Security\Set-Secure'
)

$functionsToExport = foreach ($command in $public) {
    . ('{0}\public\{1}.ps1' -f $psscriptroot, $command)

    Split-Path $command -Leaf
}

Export-ModuleMember -Function ($functionsToExport + 'GetModuleConfiguration')