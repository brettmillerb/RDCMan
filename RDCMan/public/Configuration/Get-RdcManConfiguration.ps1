function Get-RdcConfiguration {
    <#
    .SYNOPSIS
        Get the configuration for the document generator.
    .DESCRIPTION

    #>

    [CmdletBinding()]
    param (
        # Get a specific configuration value by name.
        [String]$Name,

        # Get a configuration value and test whether or not it is equal to the specified value.
        [Object]$Eq
    )

    if ($Name -and $psboundparameters.ContainsKey('Eq')) {
        $script:Configuration.$Name -eq $Eq
    } elseif ($Name) {
        $Script:configuration.$Name
    } else {
        $Script:configuration
    }
}