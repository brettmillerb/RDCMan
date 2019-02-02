# Remote Desktop Manager File Generator

~~Idea taken from Kevin Marquette's RDCMan DSL to generate the entire XML for a new file.~~

Now **very** loosely based on Kevin Marquette's RDCMan DSL blog post

https://kevinmarquette.github.io/2017-03-04-Powershell-DSL-example-RDCMan/

Entirely reworked by [Chris Dent - Indented Automation](https://github.com/indented-automation)

## Usage
RDCManager alllows you to group servers and store configuration data so you can effectively manage your server estate from one window.

This module allows you to dynamically create the document for RDCManager by extracting the data from Active Directory. This saves you having to remember to add/remove servers as they change in your estate.

The module offers the option of using the Active Directory module if RSAT tools are installed otherwise you can specify to use LDAP to perform queries.

## Generating the document

### RdcDocument
This must be specified as this is the starting point for you to begin defining groups/computers.

You can then define your document manually with the `RdcGroup` and `RdcComputer` functions.

```powershell
RdcDocument MyServers {
    RdcGroup "My First Group" {
        RdcComputer -Name 'server001' -DnsHostName 'server001.fqdn.com' -IPv4address '10.0.0.1'
        RdcComputer -Name 'server002' -DnsHostName 'server002.fqdn.com' -IPv4address '10.0.0.2'
    }
}
```
#### Output
![RDCManBasicOutput](/RDCManager/img/ZMRivZa5sA.png)


### Generating a file with specific Active Directory filtering
```powershell
RdcDocument MyServers {
    RdcGroup "My Group" {
        # Will create a group with the OU name and any computer objects within
        RdcADGroup -Identity 'OU=Newcastle,DC=millerb,DC=co,DC=uk'

        #Add -Recurse switch and it will create a group for each sub OU and add members accordingly
        RdcADGroup -Identity 'OU=London,DC=millerb,DC=co,DC=uk' -Recurse
        
        # Will search for a specific server provided by the filter recursing all OU's
        RdcADComputer -Name 'Admin*' -Recurse
    }
}
```

### Automatic creation from root of domain
This will create groups replicating the OU structure which contains computer objects.

```powershell
RdcDocument 'Domain' {
    RdcADGroup -Recurse
}
```

#### Output
![RDCManOutput](/RDCManager/img/xIkQfDVql2.png)

## Additional Functionality

#### RdcConfiguration
Sets the configuration to be used when generating the document. This is not required as if the AD module is detected this will be used unless ADSI is specified. If the AD Module is not available then ADSI LDAP filters will be used.

```powershell
RdcConfiguration @{
        SearchMode   = 'ADSI'
        FilterFormat = 'LDAP'
    }
```

#### RdcLogonCredential
Allows credentials to be set at any level to support different domains/forests. May conflict with GPO's set to prevent saved passwords being used.

```powershell
RdcLogonCredential @{
    Username = 'millerb-admin'
    Domain   = 'millerb.co.uk'
}
```
#### RdcRemoteDesktopSetting
Enables scaling of the connected client window.
```powershell
RdcRemoteDesktopSetting @{
    SameSizeAsClientArea = $true
}
```