# About 30/hr @ 5 threads

$MaxJobs = 5
$SleepTimer = 1
$users = get-content "c:\temp\SQL\usernames.txt"

$scriptblock = {
    Get-ADPrincipalGroupMembership -identity $($args[0]) | Get-ADGroup -properties * | select Name | Format-wide -column 2|out-file c:\temp\SQL\users\$($args[0]).groups.txt -append
}

ForEach ($user in $users){
    While (@(Get-Job -state running).count -ge $MaxJobs){      
    Start-Sleep -Milliseconds $SleepTimer
    } 
    If (Test-Path c:\temp\SQL\users\$user.groups.txt){
    Write-Host "Skipping $user"
        }
         else {
    Start-Job $scriptblock -ArgumentList $user -Name "$($user)job" 
    }
}

While (@(Get-Job -State Running).count -gt 0){
    Start-Sleep -Milliseconds $SleepTimer
}

ForEach($Job in Get-Job){
    Wait-Job -name $Job | Receive-Job -Job $Job 
    Remove-job $Job
}
