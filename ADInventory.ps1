Foreach ($h in (Get-Content "c:\temp\AllServers.txt")) {
    Get-ADComputer $h -properties * | Format-Table Name,OperatingSystem,OperatingSystemServicePack,OperatingSystemVersion,IPv4Address -auto -Wrap | out-file c:\temp\loot\AllComputers.csv -append
    }
