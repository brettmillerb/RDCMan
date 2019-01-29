function GetAdsiObject {
    <#
    .SYNOPSIS
        Get an arbitrary object using ADSI.
    .DESCRIPTION
        These basic ADSI commands allow the RdcMan document generator to be used without the MS AD module.

        Use of the internal commands is optional. If used, all filters must be written as LDAP filter.
    #>

    [CmdletBinding()]
    param (
        # A filter describing the computers units to find.
        [Parameter(Mandatory)]
        [String]$Filter,

        # A list of properties to retrieve
        [String[]]$Properties = 'distinguishedName',

        # The search base for this search.
        [String]$SearchBase,

        # The search scope for the search operation.
        [System.DirectoryServices.SearchScope]$SearchScope,

        # Limit the number of results returned by a search. By default result set size is unlimited.
        [Int32]$ResultSetSize,

        # The server to use to execute the search.
        [String]$Server,

        # Credentials to use when connecting to the server.
        [PSCredential]$Credential
    )

    $params = @{}
    if ($Server) { $params.Add('Server', $Server) }
    if ($Credential) { $params.Add('Credential', $Credential) }

    $params = @{}
    if ($Server) { $params.Add('Server', $Server) }
    if ($Credential) { $params.Add('Credential', $Credential) }

    if (-not $SearchBase) {
        $SearchBase = (GetAdsiRootDse @params).defaultNamingContext
    }
    $adsiSearchBase = NewDirectoryEntry -DistinguishedName $SearchBase @params

    $searcher = [ADSISearcher]@{
        Filter      = $Filter
        SearchRoot  = $adsiSearchBase
        SearchScope = $SearchScope
        PageSize    = 1000
    }
    $searcher.PropertiesToLoad.AddRange($Properties)

    if ($ResultSetSize) {
        $searcher.SizeLimit = $ResultSetSize
    }

    Write-Debug 'SEARCHER:'
    Write-Debug ('    Filter     : {0}' -f $Filter)
    Write-Debug ('    SearchBase : {0}' -f $SearchBase)
    Write-Debug ('    SearchScope: {0}' -f $SearchScope)

    foreach ($searchResult in $searcher.FindAll()) {
        $objectProperties = @{}
        foreach ($property in $Properties) {
            $objectProperties.Add($property, $searchResult.Properties[$property][0])
        }
        [PSCustomObject]$objectProperties
    }
}