function ADConfiguration {
    <#
    .SYNOPSIS
        Set the AD any AD configuration which should be used when searching Active Directory.
    .DESCRIPTION
        The ADConfiguration element provides default values for AD search operations in child scopes.

        The ADConfiguration element is expected to be used in RdcDocument or RdcGroup elements.
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [ValidateScript(
            {
                if ($_.ContainsKey('Credential') -and $_['Credential'] -isnot [PSCredential]) {
                    throw 'The credential key was present, but the value is not a credential object.'
                }
                foreach ($key in $_.Keys) {
                    if ($key -notin 'Server', 'Credential') {
                        throw ('Invalid key in the ADConfigurastion hashtable. Valid keys are Server and Credential')
                    }
                }
                $true
            }
        )]
        [Hashtable]$ADConfiguration
    )

    foreach ($key in $ADConfiguration.Keys) {
        New-Variable -Name ('RdcAD{0}' -f $key) -Value $ADConfiguration[$key] -Scope 1 -Force
    }
}