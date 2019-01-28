function RdcADComputer {
    <#
    .SYNOPSIS
        Creates a set of computers under a document or group.
    .DESCRIPTION
        RdcADComputer is used to create computer objects based on a search of Active Directory.
    #>

    [CmdletBinding(DefaultParameterSetName = 'UsingFilter')]
    param (
        # The filter which will be used to find computers.
        [Parameter(Position = 1, ParameterSetName = 'UsingFilter')]
        [String]$Filter = '*',

        # When searching by name the names are assembled into a filter for each name using the OR operator.
        [Parameter(ParameterSetName = 'ByName')]
        [String[]]$Name,

        # The search base. By default the search is performed from the root of the current domain.
        [String]$SearchBase,

        # The server to use for this operation.
        [String]$Server = (Get-Variable RdcADServer -ValueOnly -ErrorAction SilentlyContinue),

        # Credentials to use when connecting to active directory.
        [PSCredential]$Credential = (Get-Variable RdcADCredential -ValueOnly -ErrorAction SilentlyContinue),

        # If recurse is set, groups will be created representing OUs which contain computer objects.
        [Switch]$Recurse
    )

    if (-not $psboundparameters.ContainsKey('SearchBase')) {
        if ($candidateDN = Get-Variable parentDN -ValueOnly -ErrorAction SilentlyContinue) {
            $SearchBase = $candidateDN
        }
    }

    $params = @{
        SearchBase  = $SearchBase
        SearchScope = ('OneLevel', 'Subtree')[$Recurse.ToBool()]
    }
    if ($Name) {
        $params.Add('Name', $Name)
    } else {
        $params.Add('Filter', $Filter)
    }
    if ($Server) {
        $params.Add('Server', $Server)
    }
    if ($Credential) {
        $params.Add('Credential', $Credential)
    }

    GetADComputer @params |
        Sort-Object Name |
        RdcComputer
}