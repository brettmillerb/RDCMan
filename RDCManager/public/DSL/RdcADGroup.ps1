function RdcADGroup {
    <#
    .SYNOPSIS
        Create a group node derived from the content of an organisational unit.
    .DESCRIPTION
        Create a group node derived from the content of an organisational unit.
    #>

    [CmdletBinding(DefaultParameterSetName = 'UsingFilter')]
    param (
        # A filter for OU objects.
        [Parameter(Position = 1, ParameterSetName = 'UsingFilter')]
        [String]$Filter = '*',

        # The identity of a single OU.
        [Parameter(Mandatory, ParameterSetName = 'ByIdentity')]
        [String]$Identity,

        # A filter to apply when evaluating descendent computer objects.
        [String]$ComputerFilter = '*',

        # The search base to use when using a filter.
        [Parameter(ParameterSetName = 'UsingFilter')]
        [String]$SearchBase,

        # The server to use for this operation.
        [String]$Server = (Get-Variable RdcADServer -ValueOnly -ErrorAction SilentlyContinue),

        # Credentials to use when connecting to active directory.
        [PSCredential]$Credential = (Get-Variable RdcADCredential -ValueOnly -ErrorAction SilentlyContinue),

        # If Recurse is set, groups will be created in the RDC document reprsenting each child organisational unit.
        #
        # Organizational units are only included as groups if the oganizational unit contains computer accounts or other organizational units.
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

    $serverAndCredential = @{}
    if ($Server) {
        $serverAndCredential.Add('Server', $Server)
    }
    if ($Credential) {
        $serverAndCredential.Add('Credential', $Credential)
    }

    GetADOrganizationalUnit @params @serverAndCredential | ForEach-Object {
        # Determine if the OU has child objects. If so, allow it to be included.
        Write-Debug 'Searching for child computer objects'
        Write-Debug ('    SearchBase: {0}' -f $_.DistinguishedName)

        $params = @{
            Filter        = '*'
            SearchBase    = $_.DistinguishedName
            SearchScope   = 'Subtree'
            ResultSetSize = 1
        }
        if (GetADComputer @params @serverAndCredential) {
            Write-Verbose ('Creating group {0}' -f $_.Name)

            $parentDN = $_.DistinguishedName
            if ($Recurse) {
                RdcGroup $_.Name {
                    RdcADGroup -Recurse -ComputerFilter $ComputerFilter @serverAndCredential
                    RdcADComputer -SearchBase $parentDN -Filter $ComputerFilter @serverAndCredential
                }
            } else {
                RdcGroup $_.Name {
                    RdcADComputer -SearchBase $parentDN -Filter $ComputerFilter @serverAndCredential -Recurse
                }
            }
        }
    }
}