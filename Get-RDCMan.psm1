using assembly System.Xml.Linq
using namespace System.Xml.Linq

function RdcDocument {
    [CmdletBinding()]
    param (
        [Parameter(Mandatory, Position = 1)]
        [String]$FileName,

        [Parameter(Mandatory, Position = 2)]
        [ScriptBlock]$Children,

        [Switch]$Save
    )

    $xDocument = $currentNode = [XDocument]::Parse('
        <?xml version="1.0" encoding="utf-8"?>
        <Rdc programVersion="2.7" schemaVersion="3">
            <file>
                <credentialsProfiles />
                <properties>
                    <name>{0}</name>
                </properties>
            </file>
            <connected />
            <favorites />
            <recentlyUsed />
        </Rdc>'.Trim() -f $FileName)

    if ($Children) {
        & $Children
    }

    if ($Save) {
        $SaveAs = $pscmdlet.GetUnresolvedProviderPathFromPSPath('{0}.rdg' -f $FileName)
        $xDocument.Save($SaveAs)
    } else {
        $xDocument
    }
}

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

function RdcComputer {
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

function RdcADGroup {
    <#
    .SYNOPSIS
        Create a group node derived from the content of an organisational unit.
    .DESCRIPTION
        Create a group node derived from the content of an organisational unit.
    #>

    [CmdletBinding(DefaultParameterSetName = 'ByFilter')]
    param (
        [Parameter(ParameterSetName = 'ByFilter')]
        [String]$Filter = '*',

        [Parameter(Mandatory, ParameterSetName = 'ByIdentity')]
        [String]$Identity,

        [String]$ComputerFilter = '*',

        [Parameter(ParameterSetName = 'ByFilter')]
        [String]$SearchBase = (Get-ADDomain).DistinguishedName,

        [Switch]$Recurse
    )

    if (-not $psboundparameters.ContainsKey('SearchBase')) {
        if ($candidateDN = Get-Variable parentDN -ValueOnly -ErrorAction SilentlyContinue) {
            $SearchBase = $candidateDN
        }
    }

    if ($pscmdlet.ParameterSetName -eq 'ByIdentity') {
        $params = @{
            Identity = $Identity
        }
    } else {
        $params = @{
            Filter      = $Filter
            SearchBase  = $SearchBase
            SearchScope = 'OneLevel'
        }
    }

    Get-ADOrganizationalUnit @params | ForEach-Object {
        # Determine if the OU has child objects. If so, allow it to be included.
        $params = @{
            Filter      = { objectClass -eq 'organizationalUnit' -or objectClass -eq 'computer' }
            SearchBase  = $_.DistinguishedName
            SearchScope = 'OneLevel'
        }
        if (Get-ADObject @params) {
            'Creating group {0}' -f $_.Name | Write-Verbose

            $parentDN = $_.DistinguishedName
            if ($Recurse) {
                RdcGroup $_.Name {
                    RdcADGroup -Recurse -ComputerFilter $ComputerFilter
                    RdcADComputer -Filter $ComputerFilter
                }
            } else {
                RdcGroup $_.Name {
                    RdcADComputer -Filter $ComputerFilter
                }
            }
        }
    }
}

function RdcADComputer {
    [CmdletBinding()]
    param (
        [String]$Filter = '*',

        [String]$SearchBase = (Get-ADDomain).DistinguishedName,

        [Switch]$Recurse
    )

    if (-not $psboundparameters.ContainsKey('SearchBase')) {
        if ($candidateDN = Get-Variable parentDN -ValueOnly -ErrorAction SilentlyContinue) {
            $SearchBase = $candidateDN
        }
    }

    'Adding computers from {0}' -f $SearchBase | Write-Verbose

    $params = @{
        Filter      = $Filter
        Properties  = 'DisplayName', 'dnsHostName', 'IPv4Address'
        SearchBase  = $SearchBase
        SearchScope = 'OneLevel'
    }
    if ($Recurse) {
        $params.SearchScope = 'Subtree'
    }

    # Select to avoid the specialised object type breaking parameter binding.
    Get-ADComputer @params |
        Select-Object * |
        Sort-Object Name |
        RdcComputer
}