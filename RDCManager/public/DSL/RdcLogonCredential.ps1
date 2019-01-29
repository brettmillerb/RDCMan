function RdcLogonCredential {
    <#
    .SYNOPSIS
        Creates a node to save credentials in the parent group or document.
    .DESCRIPTION
        Creates a node to save credentials in the parent group or document.
    #>

    [CmdletBinding(DefaultParameterSetName = 'FromHashtable')]
    param (
        [Parameter(Position = 1, ParameterSetName = 'FromHashtable')]
        [ValidateScript(
            {
                if ($_.Contains('Password') -and $_['Password'] -isnot [SecureString]) {
                    throw 'Passwords must be stored as a secure string'
                }
                foreach ($key in $_.Keys) {
                    if ($key -notin 'Username', 'Password', 'Domain') {
                        throw ('Invalid key in the RdcLogonCredentials hashtable. Valid keys are UserName, Password, and Domain')
                    }
                }
                $true
            }
        )]
        [Hashtable]$CredentialHash,

        [Parameter(ParameterSetName = 'FromCredential')]
        [PSCredential]$Credential,

        [Switch]$SavePassword
    )

    try {
        # Get the value of the parentNode variable from the parent scope(s)
        $parentNode = Get-Variable currentNode -ValueOnly -ErrorAction Stop
    } catch {
        throw ('{0} must be nested in RdcDocument or RdcGroup: {1}' -f $myinvocation.InvocationName, $_.Exception.Message)
    }

    if ($Credential) {
        if ($Credential.Username.Contains('\')) {
            $domainName, $username = $Credential.UserName -split '\\', 2
        } else {
            $domainName = ''
            $userName = $Credential.UserName
        }
        $secureString = $Credential.Password
    } else {
        $domainName = $CredentialHash['Domain']
        $userName = $CredentialHash['UserName']
        $secureString = $CredentialHash['Password']
    }

    if ($secureString.Length -gt 0) {
        $encryptedHexString = $secureString | ConvertFrom-SecureString
        $bytes = for ($i = 0; $i -lt $encryptedHexString.Length; $i += 2) {
            [Convert]::ToByte(
                ('{0}{1}' -f $encryptedHexString[$i], $encryptedHexString[$i + 1]),
                16
            )
        }
        $encryptedPassword = [Convert]::ToBase64String($bytes)
    } else {
        $encryptedPassword = ''
    }

    # V2: BigInteger variation

    # Add-Type -AssemblyName System.Numerics
    # $bytes = [System.Numerics.BigInteger]::Parse(
    #     ($secureString | ConvertFrom-SecureString),
    #     'HexNumber'
    # ).ToByteArray()
    # [Array]::Reverse($bytes)

    # $encryptedString = [Convert]::ToBase64String($bytes)

    # [RdcMan.Encryption]::DecryptString($encryptedString, [RdcMan.EncryptionSettings]::new())

    # V3: Decrypt and reencrypt

    # $encryptedString = [Convert]::ToBase64String(
    #     [System.Security.Cryptography.ProtectedData]::Protect(
    #         [System.Text.Encoding]::Unicode.GetBytes(
    #             $Credential.GetNetworkCredential().Password
    #         ),
    #         $null,
    #         'CurrentUser'
    #     )
    # )

    $xElement = [System.Xml.Linq.XElement]('
        <logonCredentials inherit="None">
            <profileName scope="Local">Custom</profileName>
            <userName>{0}</userName>
            <password>{1}</password>
            <domain>{2}</domain>
        </logonCredentials>' -f $username, $encryptedPassword, $domainName)

    $parentNode.Element('properties').AddAfterSelf($xElement)
}