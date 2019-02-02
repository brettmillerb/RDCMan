[cmdletbinding()]
param (
    $SourceFolder = "$PSScriptRoot",
    $Destination = "$PSScriptRoot\out"
)

function Get-FilesToMerge {
    [cmdletbinding()]
    param (
        $Path = $PSScriptRoot
    )

    Get-ChildItem -Path $PSScriptRoot -Recurse -Include *.ps1 -Exclude build.ps1 |
        Sort-Object FullName | ForEach-Object {
            "Adding {0} to the psm1 file" -f $_.BaseName | Write-Verbose
            Get-Content -Path $_.FullName | Add-Content -Path $Destination\RDCManager\RDCManager.psm1
            "`r" | Add-Content -Path $Destination\RDCManager\RDCManager.psm1
        }
}

if (Test-Path -Path $PSScriptRoot\out) {
    Remove-Item -Path $Destination -Force -Confirm:$false -Recurse
}

# Remove out directory to allow rebuilding
$null = New-Item -ItemType Directory -Name RDCManager -Path $PSScriptRoot\out

Get-FilesToMerge

"Adding InitializeModule to the psm1 file" | Write-Verbose
"InitializeModule" | Add-Content -Path $Destination\RDCManager\RDCManager.psm1

"Copying Manifest file to {0}" -f $Destination | Write-Verbose
Copy-Item -Path $PSScriptRoot\RDCManager\*.psd1 -Destination $Destination\RDCManager

#$content -replace "^FunctionsToExport = '[*]'$", ("FunctionsToExport = @('{0}'`r`n)" -f ($pubfunctions -join "',`r`n`t'"))
