function RdcGroup {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, ValueFromPipeline, Position = 1)]
        [String]$Name,

        [Parameter(Mandatory, Position = 2)]
        [ScriptBlock]$Children
    )

    try {
        $parentNode = Get-Variable currentNode -ValueOnly -ErrorAction Stop
    } catch {
        throw ('{0} must be nested in RdcDocument or RdcGroup: {1}' -f $myinvocation.InvocationName, $_.Exception.Message)
    }

    $xElement = $currentNode = [XElement]('
        <group>
            <properties>
                <name>{0}</name>
            </properties>
        </group>' -f $Name)

    if ($parentNode -is [XDocument]) {
        $parentNode.Element('Rdc').Element('file').Add($xElement)
    } else {
        $parentNode.Add($xElement)
    }

    if ($Children) {
        & $Children
    }
}