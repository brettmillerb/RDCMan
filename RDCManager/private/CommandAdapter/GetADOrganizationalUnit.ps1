function GetADOrganizationalUnit {
    <#
    .SYNOPSIS
        Use either the ActiveDirectory module or ADSI to find organizational unit objects.
    .DESCRIPTION
        Use either the ActiveDirectory module or ADSI to find organizational unit objects.
    #>

    [CmdletBinding()]
    param (
        [Parameter(ParameterSetName = 'ByName')]
        [String]$Name,

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
        [PSCredential]$Credential,

        # The filter format to use.
        [String]$FilterFormat = (Get-RdcConfiguration -Name FilterFormat)
    )

    if ($pscmdlet.ParameterSetName -eq 'ByName') {
        $null = $psboundparameters.Remove('Name')

        $FilterFormat = 'LDAP'
        $Filter = '(name={0})' -f $Name
        $psboundparameters.Add('Filter', $Filter)
    }

    if (-not $SearchBase) {
        $null = $psboundparameters.Remove('SearchBase')
    }

    if (Get-RdcConfiguration -Name SearchMode -Eq ADModule) {
        if ($FilterFormat -eq 'LDAP') {
            $null = $psboundparameters.Remove('Filter')
            $psboundparameters.Add('LdapFilter', $Filter)
        }
        Get-ADOrganizationalUnit @psboundparameters
    } else {
        GetAdsiOrganizationalUnit @psboundparameters
    }
}