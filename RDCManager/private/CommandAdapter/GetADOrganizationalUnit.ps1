function GetADOrganizationalUnit {
    <#
    .SYNOPSIS
        Use either the ActiveDirectory module or ADSI to find organizational unit objects.
    .DESCRIPTION
        Use either the ActiveDirectory module or ADSI to find organizational unit objects.
    #>

    [CmdletBinding()]
    param (
        # A filter to use for the search. If using the ActiveDirectory module this can either be an LDAP filter, or the specialised form used by the ActiveDirectory module.
        [Parameter(ParameterSetName = 'UsingFilter')]
        [String]$Filter,

        # Use identity instead of a filter to locate the OU.
        [Parameter(ParameterSetName = 'ByIdentity')]
        [String]$Identity,

        # A searchbase to use. If a search base is not set, the root of the current domain is used.
        [String]$SearchBase,

        # The search scope for the search operation.
        [System.DirectoryServices.SearchScope]$SearchScope,

        # The server to use for the search.
        [String]$Server,

        # Credentials to use when connecting to the server.
        [PSCredential]$Credential
    )

    if (Get-RdcConfiguration -Name SearchMode -Eq ADModule) {
        Get-ADOrganizationalUnit @psboundparameters
    } else {
        GetAdsiOrganizationalUnit @psboundparameters
    }
}