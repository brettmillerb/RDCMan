function GetAdsiRootDSE {
    <#
    .SYNOPSIS
        Get a RootDSE node using ADSI.
    .DESCRIPTION
        These basic ADSI commands allow the RdcMan document generator to be used without the MS AD module.

        Use of the internal commands is optional. If used, all filters must be written as LDAP filter.
    #>

    [CmdletBinding()]
    param (
        [String]$Server,

        [PSCredential]$Credential
    )

    NewDirectoryEntry -DistinguisedName 'RootDSE' @psboundparameters
}