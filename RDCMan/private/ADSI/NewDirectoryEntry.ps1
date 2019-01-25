function NewDirectoryEntry {
    [CmdletBinding()]
    param (
        [String]$DistinguishedName,

        [String]$Server,

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