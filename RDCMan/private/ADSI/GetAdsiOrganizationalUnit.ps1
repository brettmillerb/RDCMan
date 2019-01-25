function GetAdsiOrganizationalUnit {
    <#
    .SYNOPSIS
        Get an organization unit object using ADSI.
    .DESCRIPTION
        These basic ADSI commands allow the RdcMan document generator to be used without the MS AD module.

        Use of the internal commands is optional. If used, all filters must be written as LDAP filter.
    #>

    [CmdletBinding()]
    param (
        # A filter describing the organizational units to find.
        [String]$Filter = '(objectClass=organizationalUnit)',

        # The search base for this search.
        [String]$SearchBase,

        # The server to use to execute the search.
        [String]$Server,

        # Credentials to use when connecting to the server.
        [PSCredential]$Credential
    )

    if ($Filter -eq '*') {
        $Filter = '(objectClass=organizationalUnit)'
    } elseif ($Filter) {
        $Filter = '(&(objectClass=organizationalUnit){0})' -f $Filter
    }

    if (-not $SearchBase) {
        $null = $psboundparameters.Remove('Filter')
        $null = $psboundparameters.Remove('SearchBase')
        $SearchBase = (GetAdsiRootDse @psboundparameters).Properties['defaultNamingContext']
    }

    $searcher = [ADSISearcher]@{
        Filter      = $Filter
        SearchRoot  = $SearchBase
        SearchScope = 'OneLevel'
        PageSize    = 1000
    }
    $searcher.PropertiesToLoad.AddRange('name', 'description')
    $searcher.FindAll()
}