function RdcComputer {
    <#
    .SYNOPSIS
        Create a computer in the RDCMan document.
    .DESCRIPTION

    #>

    [CmdletBinding(DefaultParameterSetName = 'FromPipeline')]
    param (
        [Parameter(Mandatory, ValueFromPipelineByPropertyName, ParameterSetName = 'FromPipeline')]
        [String]$Name,

        [Parameter(Position = 2, ValueFromPipelineByPropertyName, ParameterSetName = 'FromPipeline')]
        [String]$DnsHostName,

        [Parameter(Position = 3, ValueFromPipelineByPropertyName, ParameterSetName = 'FromPipeline')]
        [Alias('IPv4Address')]
        [String]$Comment,

        [Parameter(Mandatory, Position = 1, ParameterSetName = 'FromHashtable')]
        [Hashtable]$Properties
    )

    begin {
        try {
            $parentNode = Get-Variable currentNode -ValueOnly -ErrorAction Stop
        } catch {
            throw ('{0} must be nested in RdcDocument or RdcGroup: {1}' -f $myinvocation.InvocationName, $_.Exception.Message)
        }

        if ($pscmdlet.ParameterSetName -eq 'FromHashTable') {
            foreach ($key in $Properties.Keys) {
                if ($key -notin 'Name', 'DnsHostName', 'Comment') {
                    throw ('Invalid key in Properties hashtable. Valid keys are Name, DnsHostName, and Comment')
                }
            }
            if (-not $Properties.ContainsKey('Name')) {
                throw 'The Name key must be present'
            }
        }
    }

    process {
        if ($Properties) {
            $Name = $Properties.Name
            $DnsHostName = $Properties.DnsHostName
            $Comment = $Properties.Comment
        }
        if (-not $DnsHostName) {
            $DnsHostName = $Name
        }

        $xElement = [XElement]('
            <server>
                <properties>
                    <displayname>{0}</displayname>
                    <name>{1}</name>
                    <comment>{2}</comment>
                </properties>
            </server>' -f $Name, $DnsHostName, $Comment)

        if ($parentNode -is [XDocument]) {
            $parentNode.Element('Rdc').Element('connected').AddBeforeSelf($xElement)
        } else {
            $parentNode.Element('properties').AddAfterSelf($xElement)
        }
    }
}