# Remote Desktop Manager File Generator ###

Built upon Kevin Marquette's RDCMan DSL to generate the entire XML for a new file.

https://kevinmarquette.github.io/2017-03-04-Powershell-DSL-example-RDCMan/

## Usage
```
RDCFile "Server List" {
    RDCGroup "Group001" {
        RDCServer $comp1
        RDCServer $comp2
    }
    RDCGroup "Group002" {
        RDCServer $comp4
        RDCServer $comp5
    }
} | Out-File C:\temp\Servers.rdg -encoding utf8
```
## Output

```
<?xml version="1.0" encoding="utf-8"?>
<RDCMan programVersion="2.7" schemaVersion="3">
            <file>
                <credentialsProfiles />
                <properties>
                    <name>Server List</name>
                </properties>
            <group>
            <properties>
                <name>Group001</name>
            </properties>
                    <server>
                        <properties>
                        <displayname>server001</displayname>
                        <name>server001.fqdn.domain.com</name>
                        <comment>10.0.0.1</comment>
                        </properties>
                    </server>
                    <server>
                        <properties>
                        <displayname>server002</displayname>
                        <name>server002.fqdn.domain.com</name>
                        <comment>10.0.0.2</comment>
                        </properties>
                    </server>
            </group>
            <group>
            <properties>
                <name>Group002</name>
            </properties>
                    <server>
                        <properties>
                        <displayname>server004</displayname>
                        <name>server004.fqdn.domain.com</name>
                        <comment>10.0.0.3</comment>
                        </properties>
                    </server>
                    <server>
                        <properties>
                        <displayname>server005</displayname>
                        <name>server005.fqdn.domain.com</name>
                        <comment>10.0.0.4</comment>
                        </properties>
                    </server>
            </group>
            </file>
            <connected />
            <favorites />
            <recentlyUsed />
        </RDCMan>
```