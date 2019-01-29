# Development root module

$private = @(
    'ADSI\GetAdsiComputer'
    'ADSI\GetAdsiObject'
    'ADSI\GetAdsiOrganizationalUnit'
    'ADSI\GetAdsiRootDSE'
    'ADSI\NewDirectoryEntry'
    'CommandAdapter\GetADComputer'
    'CommandAdapter\GetADObject'
    'CommandAdapter\GetADOrganizationalUnit'
)

foreach ($command in $private) {
    . ('{0}\private\{1}.ps1' -f $psscriptroot, $command)

    Split-Path $command -Leaf
}

$public = @(
    'Configuration\Get-RdcConfiguration'
    'Configuration\Set-RdcConfiguration'
    'DSL\ADConfiguration'
    'DSL\RdcADComputer'
    'DSL\RdcADGroup'
    'DSL\RdcComputer'
    'DSL\RdcConfiguration'
    'DSL\RdcDocument'
    'DSL\RdcGroup'
    'DSL\RdcLogonCredential'
)

$functionsToExport = foreach ($command in $public) {
    . ('{0}\public\{1}.ps1' -f $psscriptroot, $command)

    Split-Path $command -Leaf
}

. ('{0}\InitializeModule.ps1' -f $psscriptroot)
InitializeModule

Export-ModuleMember -Function $functionsToExport