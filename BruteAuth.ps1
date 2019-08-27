Function Get-Auth  {
 
if  ($args.Count -eq 0) {
    Write-Host "Example: auth 192.168.0"
    exit
}
 
for ($j = 0; $j -lt $args.count; $j ++) {
    # loop current ip range    
    $ip = $args[$j] + "."
    
    ForEach ($i in 2..254) {
        
        # get each ip
        $cur = $ip + $i
        
        # auth once
        $SPAdmin = "$cur\Administrator" 
        # Read-Host "DOMAIN\USERNAME" -AsSecureString | ConvertFrom-SecureString | Out-File C:\users\<user>\Desktop\SecureString.txt
        $Password = Get-Content C:\users\<user>\Desktop\SecureString.txt | convertto-securestring 
        $Searcher = [WmiSearcher]'SELECT * FROM Win32_Service'
        $Searcher.Options.TimeOut = "0:0:5"
        $ConnectionOptions = New-Object Management.ConnectionOptions
        $ManagementScope = New-Object Management.ManagementScope("\\$cur\root\cimv2", $ConnectionOptions)
        $Searcher.Scope = $ManagementScope
        $Credential = new-object -typename System.Management.Automation.PSCredential -argumentlist $SPAdmin, $Password 
        Get-WmiObject -Class Win32_Service -ComputerName $cur -Credential $Credential
            if ($LASTEXITCODE -eq 0) {
                Write-Host "$cur has a valid Administrator login!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!!"
            } else {
                Write-Host "$cur does not have a valid login"
            }
    }
}


}
