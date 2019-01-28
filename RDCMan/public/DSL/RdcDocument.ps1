function RdcDocument {
    <#
    .SYNOPSIS
        Declare an RDCMan document.
    .DESCRIPTION
        An RDC Document defines the basic document content and is the starting point for creating groups and computer elements.
    #>

    [CmdletBinding()]
    param (
        # The path to a file to save content.
        [Parameter(Mandatory, Position = 1)]
        [Alias('FileName', 'FullName')]
        [String]$Path,

        # A script block defining the content of the document.
        [Parameter(Mandatory, Position = 2)]
        [ScriptBlock]$Children
    )

    $xDocument = $currentNode = [System.Xml.Linq.XDocument]::Parse('
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
        </Rdc>'.Trim() -f ([System.IO.FileInfo]$Path).BaseName)

    if ($Children) {
        & $Children
    }

    if ($Path -notmatch '\.rdg$') {
        $Path = '{0}.rdg' -f $Path
    }
    $Path = $pscmdlet.GetUnresolvedProviderPathFromPSPath($Path)
    $xDocument.Save($Path)
}