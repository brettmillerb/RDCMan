function RdcADGroup {
    <#
    .SYNOPSIS
        Create a group node derived from the content of an organisational unit.
    .DESCRIPTION
        Create a group node derived from the content of an organisational unit.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByFilter')]
    param (
        [Parameter(ParameterSetName = 'ByFilter')]
        [String]$Filter = '*',

        [Parameter(Mandatory, ParameterSetName = 'ByIdentity')]
        [String]$Identity,

        [String]$ComputerFilter = '*',

        [Parameter(ParameterSetName = 'ByFilter')]
        [String]$SearchBase = (Get-ADDomain).DistinguishedName,

        [Switch]$Recurse
    )

    if (-not $psboundparameters.ContainsKey('SearchBase')) {
        if ($candidateDN = Get-Variable parentDN -ValueOnly -ErrorAction SilentlyContinue) {
            $SearchBase = $candidateDN
        }
    }

    if ($pscmdlet.ParameterSetName -eq 'ByIdentity') {
        $params = @{
            Identity = $Identity
        }
    } else {
        $params = @{
            Filter      = $Filter
            SearchBase  = $SearchBase
            SearchScope = 'OneLevel'
        }
    }

    Get-ADOrganizationalUnit @params | ForEach-Object {
        # Determine if the OU has child objects. If so, allow it to be included.
        $params = @{
            Filter      = { objectClass -eq 'organizationalUnit' -or objectClass -eq 'computer' }
            SearchBase  = $_.DistinguishedName
            SearchScope = 'OneLevel'
        }
        if (Get-ADObject @params) {
            'Creating group {0}' -f $_.Name | Write-Verbose

            $parentDN = $_.DistinguishedName
            if ($Recurse) {
                RdcGroup $_.Name {
                    RdcADGroup -Recurse -ComputerFilter $ComputerFilter
                    RdcADComputer -Filter $ComputerFilter
                }
            } else {
                RdcGroup $_.Name {
                    RdcADComputer -Filter $ComputerFilter
                }
            }
        }
    }
}