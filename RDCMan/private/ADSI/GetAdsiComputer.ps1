function GetAdsiComputer {
    <#
    .SYNOPSIS
        Get an organization unit object using ADSI.
    .DESCRIPTION
        These basic ADSI commands allow the RdcMan document generator to be used without the MS AD module.

        Use of the internal commands is optional. If used, all filters must be written as LDAP filter.
    #>

    [CmdletBinding()]
    param (
        # A filter describing the computers units to find.
        [String]$Filter = '(&(objectCategory=computer)(objectClass=computer))',

        # The search base for this search.
        [String]$SearchBase,

        [System.DirectoryServices.Protocols.SearchScope]$SearchScope = 'OneLevel',

        # The server to use to execute the search.
        [String]$Server,

        # Credentials to use when connecting to the server.
        [PSCredential]$Credential,
    )

    if ($Filter -eq '*') {
        $Filter = '(&(objectCategory=computer)(objectClass=computer))'
    } elseif ($Filter) {
        $Filter = '(&(objectCategory=computer)(objectClass=computer){0})' -f $Filter
    }

    $params = @{}
    if ($Server)     { $params.Add('Server', $Server) }
    if ($Credential) { $params.Add('Credential', $Credential) }

    if ($SearchBase) {
        $adsiSearchBase = NewDirectoryEntry -DistinguishedName $SearchBase @params
    } else {
        $adsiSearchBase = (GetAdsiRootDse @params).Properties['defaultNamingContext']
    }

    $searcher = [ADSISearcher]@{
        Filter      = $Filter
        SearchRoot  = $adsiSearchBase
        SearchScope = $SearchScope
        PageSize    = 1000
    }
    $searcher.PropertiesToLoad.AddRange(@('name', 'description', 'dnsHostName'))
    foreach ($searchResult in $searcher.FindAll()) {
        [PSCustomObject]@{
            Name        = $searchResult.Properties['name'][0]
            Description = $searchResult.Properties['description'][0]
            DnsHostName = $searchResult.Properties['dnsHostName'][0]
        }
    }
}