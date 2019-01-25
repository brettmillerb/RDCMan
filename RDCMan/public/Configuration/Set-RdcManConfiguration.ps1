function Set-RdcConfiguration {
    <#
    .SYNOPSIS
        Set the configuration for the document generator.
    .DESCRIPTION
        Sets the configuration used by the document generator.
    #>

    [CmdletBinding()]
    param (
        # Set the search mode used when building content from AD.
        #
        # The following values may be set:
        #
        #   - ADModule: Uses the MS ActiveDirectory module.
        #   - ADSI: Uses the ADSI search commands in this module.
        #
        # The default search mode is ADModule if the ActiveDirectory module is available on the computer. Otherwise the search mode defaults to ADSI.
        #
        # If the ActiveDirectory module is made available using implicit remoting this option must be set.
        [ValidateSet('ADModule', 'ADSI')]
        [String]$ADSearchMode,

        # Reset the configuration to the default.
        [Switch]$Reset
    )

    if ($Reset) {
        $Script:configuration = [PSCustomObject]@{
            ADSearchMode = ('ADModule', 'ADSI')[[Boolean](Get-Module ActiveDirectory -ListAvailable)]
        }
    } else {
        foreach ($parameterName in $psboundparameters.Keys) {
            if ($Script:configuration.PSObject.Properties.Item($parameterName)) {
                $Script:configuration.$parameterName = $psboundparameters[$parmeterName]
            }
        }
    }
}