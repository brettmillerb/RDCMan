function RdcGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position = 1)]
        [String]$Name,

        [Parameter(Mandatory, Position = 2)]
        [ScriptBlock]$Children
    )

    try {
        # Get the value of the parentNode variable from the parent scope(s)
        $parentNode = Get-Variable currentNode -ValueOnly -ErrorAction Stop
    } catch {
        throw ('{0} must be nested in RdcDocument or RdcGroup: {1}' -f $myinvocation.InvocationName, $_.Exception.Message)
    }

    $xElement = $currentNode = [System.Xml.Linq.XElement]::new('group',
        [System.Xml.Linq.XElement]::new('properties',
            [System.Xml.Linq.XElement]::new('name', $Name)
        )
    )

    if ($parentNode -is [System.Xml.Linq.XDocument]) {
        $parentNode.Element('Rdc').Element('file').Add($xElement)
    } else {
        $parentNode.Add($xElement)
    }

    if ($Children) {
        & $Children
    }
}