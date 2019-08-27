# Data input source. List all CIFS SPNs in spnHost.txt

$servers = Get-Content "C:\temp\spnHost.txt"

# Initialize Tracking
$start = Get-Date
$i = 0
$total = $servers.Count



foreach( $server in $servers ) {
	# Progress Tracking
	$i++
	$prct = [Math]::Round((($i / $total) * 100.0), 2)
 
	$elapsed = (Get-Date) - $start
	$totalTime = ($elapsed.TotalSeconds) / ($prct / 100.0)
	$remain = $totalTime - $elapsed.TotalSeconds
	$eta = (Get-Date).AddSeconds($remain)
	
	# Display
	Write-Progress -Activity "ETA $eta" -Status "$prct" -PercentComplete $prct

    # Operation
    echo $server | Out-File c:\temp\shares\$server-Shares.txt -append
    (net view \\$server | Where-Object { $_ -match '\sDisk\s' }) -replace '\s\s+', ',' | ForEach-Object{ ($_ -split ',')[0] } | out-File c:\temp\shares\$server-Shares.txt -append
} 
