# Remote Desktop Manager File Generator ###

Built upon Kevin Marquette's RDCMan DSL to generate the entire XML for a new file.

https://kevinmarquette.github.io/2017-03-04-Powershell-DSL-example-RDCMan/

## Usage
```
RDCFile "Server List" {
    RDCGroup "Group001" {
        RDCServer "Server001"
        RDCServer "Server002"
    }
    RDCGroup "Group002" {
        RDCServer "Server003"
        RDCServer "Server004"
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
                <displayname></displayname>
                <name></name>
                <comment></comment>
                </properties>
            </server>
            <server>
                <properties>
                <displayname></displayname>
                <name></name>
                <comment></comment>
                </properties>
            </server>
    </group>
    <group>
    <properties>
        <name>Group002</name>
    </properties>
            <server>
                <properties>
                <displayname></displayname>
                <name></name>
                <comment></comment>
                </properties>
            </server>
            <server>
                <properties>
                <displayname></displayname>
                <name></name>
                <comment></comment>
                </properties>
            </server>
    </group>
    </file>
    <connected />
    <favorites />
    <recentlyUsed />
</RDCMan>
```