Start-transcript
$date = get-date
echo "Start time: " $date

$Filter = "(&(objectCategory=computer)(servicePrincipalName=host/*))"
$Domain = New-Object System.DirectoryServices.DirectoryEntry
$Searcher = New-Object System.DirectoryServices.DirectorySearcher
$Searcher.SearchRoot = $Domain
$Searcher.PageSize = 200
$Searcher.Filter = $Filter
$Searcher.SearchScope = "Subtree"

$Searcher.PropertiesToLoad.Add("samAccountName") > $Null
$Searcher.PropertiesToLoad.Add("operatingSystem") > $Null
#$Searcher.PropertiesToLoad.Add("serviceprincipalname") > $Null

$Results = $Searcher.FindAll()

ForEach ($Result In $Results)
{
    # Attribute names here are case insensitive.
    $SAM = $Result.Properties.Item("samAccountName")
    $OSName = $Result.Properties.Item("operatingSystem")
    #$SPName = $Result.Properties.Item("serviceprincipalname")

    ($s = "$SAM,$OSName") | out-file c:\temp\spnHOST.csv -Append
    $s.Substring(0, $s.IndexOf('$')) | out-file c:\temp\spnHost.txt -append
} 
echo "Stop AD SPN lookup time: " $date

# ----------------------------------------------------------

echo "Start Share lookup time: " $date
# Data input source
$servers = Get-Content "C:\temp\spnHost.txt"


# Speed settings
$MaxThreads = 8
$SleepTimer = 100

$scriptblock = {
    (net view "\\$($args[0])"| Where-Object { $_ -match '\sDisk\s|Platte' }) -replace '\s\s+', ',' | ForEach-Object{ ($_ -split ',')[0] } | out-File "c:\temp\shares\$($args[0])-Shares.txt" 
    #start-sleep -milliseconds 300
    $ShareLists = Get-Content c:\temp\shares\$($args[0])-Shares.txt
    foreach ($shareList in $ShareLists){
        echo "Share name: " $ShareList | out-file C:\temp\Shares\$($args[0])-ACL.txt -append
        Get-Acl \\$($args[0])\$ShareList | select path, Owner -ExpandProperty access | select owner, IdentityReference | out-file C:\temp\Shares\$($args[0])-ACL.txt -append
        }
}


ForEach ($server in $servers){
    While (@(Get-Job -state running).count -ge $MaxThreads){      
    Start-Sleep -Milliseconds $SleepTimer
    } 
    If (Test-Path C:\temp\Shares\$server-Share.txt){    #Skip if the host has already been processed
    Write-Host "Skipping $server"
        }
         else {
    Start-Job $scriptblock -ArgumentList $server -Name "$($server)-job" 
    }
}


While (@(Get-Job -State Running).count -gt 0){
    Start-Sleep -Milliseconds $SleepTimer
}


ForEach($Job in Get-Job){
    Wait-Job -name $Job | Receive-Job -Job $Job 
    Remove-job -Force $Job
}

echo "Stop Share Permissions time: " $date
Stop-transcript
