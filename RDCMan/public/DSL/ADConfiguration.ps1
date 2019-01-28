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

    try {
        # Get the value of the parentNode variable from the parent scope(s)
        $parentNode = Get-Variable currentNode -ValueOnly -ErrorAction Stop
    } catch {
        throw ('{0} must be nested in RdcDocument or RdcGroup: {1}' -f $myinvocation.InvocationName, $_.Exception.Message)
    }

    foreach ($key in $ADConfiguration.Keys) {
        New-Variable -Name ('RdcAD{0}' -f $key) -Value $ADConfiguration[$key] -Scope 1 -Force
    }
}