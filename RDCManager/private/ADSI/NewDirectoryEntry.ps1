function NewDirectoryEntry {
    <#
    .SYNOPSIS
        Creates a System.DirectoryServices.DirectoryEntry object.
    .DESCRIPTION
        Creates a System.DirectoryServices.DirectoryEntry object.
    #>

    [CmdletBinding()]
    param (
        # The distinguished name to connect to.
        [String]$DistinguishedName,

        # The server used for the connection.
        [String]$Server,

        # Any credentials which should be used.
        [PSCredential]$Credential
    )

    if ($Server) {
        $Path = 'LDAP://{0}/{1}' -f $Server, $DistinguishedName
    } else {
        $Path = 'LDAP://{0}' -f $DistinguishedName
    }
    if ($Credential) {
        [ADSI]::new($Path, $Credential.Username, $Credential.GetNetworkCredential().Password)
    } else {
        [ADSI]::new($Path)
    }
}