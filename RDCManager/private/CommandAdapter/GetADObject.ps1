function GetADObject {
    <#
    .SYNOPSIS
        Use either the ActiveDirectory module or ADSI to find arbitrary objects.
    .DESCRIPTION
        Use either the ActiveDirectory module or ADSI to find arbitrary objects.
    #>

    [CmdletBinding()]
    param (
        # A filter to use for the search. If using the ActiveDirectory module this can either be an LDAP filter, or the specialised form used by the ActiveDirectory module.
        [String]$Filter,

        # A searchbase to use. If a search base is not set, the root of the current domain is used.
        [String]$SearchBase,

        # The search scope for the search operation.
        [System.DirectoryServices.SearchScope]$SearchScope,

        # The server to use for the search.
        [String]$Server,

        # Credentials to use when connecting to the server.
        [PSCredential]$Credential
    )

    $null = $psboundparameters.Remove('FilterFormat')
    if ($pscmdlet.ParameterSetName -eq 'ByName') {
        $null = $psboundparameters.Remove('Name')

        $FilterFormat = 'LDAP'
        $nameFilters = foreach ($value in $Name) {
            '(name={0})' -f $value
        }
        $Filter = '(|{0})' -f (-join $nameFilters)
        $psboundparameters.Add('Filter', $Filter)
    }

    if (Get-RdcConfiguration -Name SearchMode -Eq ADModule) {
        if ($FilterFormat -eq 'LDAP') {
            $null = $psboundparameters.Remove('Filter')
            $psboundparameters.Add('LdapFilter', $Filter)
        }
        Get-ADComputer @psboundparameters
    } else {
        GetAdsiObject @psboundparameters
    }
}