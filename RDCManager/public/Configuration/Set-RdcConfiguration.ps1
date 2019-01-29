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
        [Parameter(ParameterSetName = 'Update')]
        [ValidateSet('ADModule', 'ADSI')]
        [String]$SearchMode,

        # The format used for filters. By default LDAP format is used when the search mode is ADSI. The ActiveDirectory format is used if the module is used.
        [Parameter(ParameterSetName = 'Update')]
        [ValidateSet('ADModule', 'LDAP')]
        [String]$FilterFormat,

        # Reset the configuration to the default.
        [Parameter(ParameterSetName = 'Reset')]
        [Switch]$Reset
    )

    if ($pscmdlet.ParameterSetName -eq 'Reset') {
        [Boolean]$isADModulePresent = Get-Module ActiveDirectory -ListAvailable

        $Script:configuration = [PSCustomObject]@{
            SearchMode   = ('ADSI', 'ADModule')[$isADModulePresent]
            FilterFormat = ('LDAP', 'ADModule')[$isADModulePresent]
        }
    } else {
        if ($SearchMode -and -not $FilterFormat) {
            if ($SearchMode -eq 'ADSI') {
                $psboundparameters['FilterFormat'] = 'LDAP'
            } else {
                $psboundparameters['FilterFormat'] = 'ADModule'
            }
        }

        foreach ($parameterName in $psboundparameters.Keys) {
            if ($Script:configuration.PSObject.Properties.Item($parameterName)) {
                $Script:configuration.$parameterName = $psboundparameters[$parameterName]
            }
        }
    }
}