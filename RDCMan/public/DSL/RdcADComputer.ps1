function RdcADComputer {
    <#
    .SYNOPSIS
        Creates a set of computers under a document or group.
    .DESCRIPTION
        RdcADComputer is used to create computer objects based on a search of Active Directory.
    #>

    [CmdletBinding()]
    param (
        # The filter which will be used to find computers.
        [String]$Filter = '*',

        # The search base. By default the search is performed from the root of the domain.
        [String]$SearchBase = (Get-ADDomain).DistinguishedName,

        # If recurse is set, groups will be created representing OUs which contain computer objects.
        [Switch]$Recurse
    )

    if (-not $psboundparameters.ContainsKey('SearchBase')) {
        if ($candidateDN = Get-Variable parentDN -ValueOnly -ErrorAction SilentlyContinue) {
            $SearchBase = $candidateDN
        }
    }

    Write-Verbose ('Adding computers from {0}' -f $SearchBase)

    $params = @{
        Filter      = $Filter
        Properties  = 'DisplayName', 'dnsHostName', 'IPv4Address'
        SearchBase  = $SearchBase
        SearchScope = 'OneLevel'
    }
    if ($Recurse) {
        $params.SearchScope = 'Subtree'
    }

    # Select to avoid the specialised object type breaking parameter binding.
    Get-ADComputer @params |
        Select-Object * |
        Sort-Object Name |
        RdcComputer
}