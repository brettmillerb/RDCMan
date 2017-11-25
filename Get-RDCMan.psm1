function Get-RDCManFile {
    [CmdletBinding()]
    Param (
        [Parameter(Mandatory = $true,
                   Position = 0)]
        [string]$FileName,

        [Parameter(Mandatory = $true,
                   Position = 1)]
        [scriptblock]$childitem
    )
    process {
        @"
        <?xml version="1.0" encoding="utf-8"?>
        <RDCMan programVersion="2.7" schemaVersion="3">
            <file>
                <credentialsProfiles />
                <properties>
                    <name>$FileName</name>
                </properties>
"@
        $childitem.Invoke()
        '            </file>
            <connected />
            <favorites />
            <recentlyUsed />
        </RDCMan>'
    }
}

function Get-RdcGroup {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
                   ValueFromPipelineByPropertyName = $true,
                   Position = 0)]
        [string]$GroupName,

        [Parameter(Mandatory = $true,
                   Position = 1)]
        [scriptblock]$ChildItem
    )
    process {
        @"
            <group>
            <properties>
                <name>$GroupName</name>
            </properties>
"@
       $ChildItem.Invoke()

        '            </group>'
    }
}

function Get-RdcServer {
    [CmdletBinding()]
    param(
        [Parameter(Mandatory = $true,
            ValueFromPipeline = $true,
            Position = 0)]
        [object[]]$ComputerName
    )
    process {
        foreach($node in $ComputerName) {
            @"
                    <server>
                        <properties>
                        <displayname>$($node.name)</displayname>
                        <name>$($node.dnshostname)</name>
                        <comment>$($node.ipv4address)</comment>
                        </properties>
                    </server>
"@
        }
    }
}