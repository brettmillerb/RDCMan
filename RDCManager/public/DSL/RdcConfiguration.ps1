function RdcConfiguration {
    <#
    .SYNOPSIS

    .DESCRIPTION
        RdcConfiguration allows the generator behaviours to be defined using a node in the document.
    .EXAMPLE
        RdcDocument name {
            RdcConfiguration @{
                SearchMode = 'ADSI'
            }
        }
    #>

    [CmdletBinding()]
    param (
        [Parameter(Mandatory)]
        [Hashtable]$Configuration
    )

    Set-RdcConfiguration @Configuration
}