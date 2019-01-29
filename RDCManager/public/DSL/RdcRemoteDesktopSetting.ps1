function RdcRemoteDesktopSetting {
    <#
    .SYNOPSIS
        Creates a node to configure remote desktop settings in the parent group or document.
    .DESCRIPTION
        Creates a node to configure remote desktop settings in the parent group or document.
    #>

    [CmdletBinding(DefaultParameterSetName = 'FromHashtable')]
    param (
        # Remote Destkop Settings configuration.
        #
        # Remote destkop settings allows the following to be defined:
        #
        #  - Size - A value in the form Horizontal x Vertical.
        #  - SameSizeAsClientArea - True or False. Make the remote desktop area fill the client window pane.
        #  - FullScreen - True or False. Make the remote desktop full screen.
        #  - ColorDepth - By default 24. ColorDepth can be set to 8, 15, 16, 24, or 32.
        [Parameter(Position = 1, ParameterSetName = 'FromHashtable')]
        [ValidateScript(
            {
                foreach ($key in $_.Keys) {
                    if ($key -notin 'Size', 'SameSizeAsClientArea', 'FullScreen', 'ColorDepth') {
                        throw ('Invalid key in the RdcLogonCredentials hashtable. Valid keys are Size, SameSizeAsClientArea, FullScreen, and ColorDepth')
                    }
                }
                $true
            }
        )]
        [Hashtable]$SettingsHash
    )

    try {
        # Get the value of the parentNode variable from the parent scope(s)
        $parentNode = Get-Variable currentNode -ValueOnly -ErrorAction Stop
    } catch {
        throw ('{0} must be nested in RdcDocument or RdcGroup: {1}' -f $myinvocation.InvocationName, $_.Exception.Message)
    }

    $settings = @{
        Size                 = $null
        SameSizeAsClientArea = $false
        FullScreen           = $true
        ColorDepth           = 24
    }
    foreach ($setting in $SettingsHash.Keys) {
        $settings[$setting] = $settingsHash[$setting]
    }
    if ($SettingsHash.Contains('SameSizeAsClientArea') -and $SettingsHash['SameSizeAsClientArea']) {
        $settings['FullScreen'] = $false
    }

    if ($settings['ColorDepth'] -notin 8, 15, 16, 24, 32) {
        throw 'Invalid color depth. Valid values are 8, 15, 16, 24, and 32.'
    }
    if ($settings['Size'] -and $settings['Size'] -notmatch '^\d+ *x *\d+$') {
        throw 'Invalid desktop size. Sizes must be specified in the format "Horizontal x Vertical"'
    } elseif ($settings['Size'] -match '^(\d+) *x *(\d+)$') {
        # Ensure Size is formatted exactly as RdcMan expects it to be.
        $settings['Size'] = '{0} x {1}' -f $matches[1], $matches[2]
    }

    $xElement = [System.Xml.Linq.XElement]('
        <remoteDesktop inherit="None">
            <sameSizeAsClientArea>{0}</sameSizeAsClientArea>
            <fullScreen>{1}</fullScreen>
            <colorDepth>{2}</colorDepth>
        </remoteDesktop>' -f $settings['SameSizeAsClientArea'], $settings['FullScreen'], $settings['ColorDepth'])

    if (-not $settings['FullScreen'] -and $settings['Size']) {
        $null = $xElement.Element('remoteDestkop').AddFirst(
            [System.Xml.Linq.XElement]('<size>{0}</size>' -f $settings['Size'])
        )
    }

    if ($parentNode -is [System.Xml.Linq.XDocument]) {
        $parentNode.Element('Rdc').Element('file').Add($xElement)
    } else {
        $parentNode.Add($xElement)
    }
}