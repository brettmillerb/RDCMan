BeforeAll {
    . $PSCommandPath.Replace('.Tests.ps1','.ps1')

    function Set-RdcConfiguration {}
}

Describe "InitializeModule" {
    BeforeAll {
        Mock -Verifiable Set-RdcConfiguration {}
    }
    It "Resets the configuration" {
        InitializeModule
        Should -InvokeVerifiable
    }
}
