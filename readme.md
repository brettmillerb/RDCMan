# Remote Desktop Manager File Generator ###

Idea taken from Kevin Marquette's RDCMan DSL to generate the entire XML for a new file.

https://kevinmarquette.github.io/2017-03-04-Powershell-DSL-example-RDCMan/

Reworked by [Chris Dent - Indented Automation](https://github.com/indented-automation)

## Usage

### Manual computers

Generates a file based on a manually defined list of computers.
```powershell
RdcDocument 'manual' -Save {
    RdcGroup 'Manual list' {
        RdcComputer @{
            Name = 'somehost1'
        }
        RdcComputer @{
            Name = 'somehost2'
        }
    }
}
```
### Manual groups. Computers from AD.
```powershell
RdcDocument 'simpleAD' -Save {
    RdcGroup 'some servers' {
        RdcADComputer -Filter { name -like 'some*' } -Recurse
    }
    RdcGroup 'other servers' {
        RdcADComputer -Filter { name -like 'other*' } -Recurse
    }
}
```
### Automatic creation from OU structure
```powershell
RdcDocument 'SomeOU' -Save {
    RdcADGroup -Identity 'OU=SomeOU,DC=somewhere,DC=com' -Recurse
}
```
### Automatic creation from domain root
```powershell
RdcDocument 'Domain' -Save {
    RdcADGroup -Recurse
}
```
