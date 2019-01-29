function GetAdsiComputer {
    <#
    .SYNOPSIS
        Get an computer object using ADSI.
    .DESCRIPTION
        These basic ADSI commands allow the RdcMan document generator to be used without the MS AD module.

        Use of the internal commands is optional. If used, all filters must be written as LDAP filter.
    #>

    [CmdletBinding()]
    param (
        # A filter describing the computers units to find.
        [String]$Filter,

        # The search base for this search.
        [String]$SearchBase,

        # The search scope for the search operation.
        [System.DirectoryServices.SearchScope]$SearchScope,

        # The server to use to execute the search.
        [String]$Server,

        # Credentials to use when connecting to the server.
        [PSCredential]$Credential
    )

    if ($Filter -eq '*' -or -not $Filter) {
        $psboundparameters['Filter'] = '(&(objectCategory=computer)(objectClass=computer))'
    } else {
        $psboundparameters['Filter'] = '(&(objectCategory=computer)(objectClass=computer){0})' -f $Filter
    }

    GetAdsiObject -Properties 'name', 'description', 'dnsHostName' @psboundparameters
}