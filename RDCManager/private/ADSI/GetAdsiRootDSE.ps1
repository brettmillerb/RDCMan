function GetAdsiRootDse {
    <#
    .SYNOPSIS
        Get a RootDSE node using ADSI.
    .DESCRIPTION
        These basic ADSI commands allow the RdcMan document generator to be used without the MS AD module.

        Use of the internal commands is optional. If used, all filters must be written as LDAP filter.
    #>

    [CmdletBinding()]
    param (
        # The server to use for the ADSI connection.
        [String]$Server,

        # Credentials to use when connecting to the server.
        [PSCredential]$Credential
    )

    $rootDSE = NewDirectoryEntry -DistinguishedName 'RootDSE' @psboundparameters
    $properties = @{}
    foreach ($property in $rootDSE.Properties.Keys) {
        $properties.Add($property, $rootDSE.Properties[$property])
    }
    [PSCustomObject]$properties
}