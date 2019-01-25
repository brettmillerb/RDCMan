function GetADComputer {
    <#
    .SYNOPSIS
        Calls the computer searcher.
    #>

    [CmdletBinding()]
    param (
        [String]$Filter,

        [String]$SearchBase,

        [String]$Server
    )

    if (Get-RdcManConfiguration -Name ADSearchMode -Eq ActiveDirectory) {
        Get-ADComputer @psboundparameters
    } else {
        GetAdsiComputer @psboundparameters
    }
}