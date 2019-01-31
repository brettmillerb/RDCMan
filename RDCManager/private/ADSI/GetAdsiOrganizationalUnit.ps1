function GetAdsiOrganizationalUnit {
    <#
    .SYNOPSIS
        Get an organization unit object using ADSI.
    .DESCRIPTION
        These basic ADSI commands allow the RdcMan document generator to be used without the MS AD module.

        Use of the internal commands is optional. If used, all filters must be written as LDAP filter.
    #>

    [CmdletBinding(DefaultParameterSetName = 'UsingFilter')]
    param (
        # A filter describing the organizational units to find.
        [Parameter(ParameterSetName = 'UsingFilter')]
        [String]$Filter,

        # Use identity instead of a filter to locate the OU.
        [Parameter(ParameterSetName = 'ByIdentity')]
        [String]$Identity,

        # The search base for this search.
        [String]$SearchBase,

        # The search scope for the search operation.
        [System.DirectoryServices.SearchScope]$SearchScope,

        # The server to use to execute the search.
        [String]$Server,

        # Credentials to use when connecting to the server.
        [PSCredential]$Credential
    )

    if ($Identity) {
        $psboundparameters['Filter'] = '(&(objectClass=organizationalUnit)(distinguishedName={0}))' -f $Identity
        $psboundparameters['SearchScope'] = 'Subtree'
        $null = $psboundparameters.Remove('Identity')
    } elseif ($Filter -eq '*' -or -not $Filter) {
        $psboundparameters['Filter'] = '(objectClass=organizationalUnit)'
    } else {
        $psboundparameters['Filter'] = '(&(objectClass=organizationalUnit){0})' -f $Filter
    }

    GetAdsiObject -Properties 'name', 'description', 'distinguishedName' @psboundparameters
}