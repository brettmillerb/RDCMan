Add-Type -AssemblyName System.Xml.Linq

function InitializeModule {
    Set-RdcConfiguration -Reset
}
