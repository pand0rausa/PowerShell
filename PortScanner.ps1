# This script will read a list of IP addresses from a file called IPAddresses.txt in the same directory as the script. 
# Then, it will loop through each IP address, creating a specified number of jobs, splitting the ports into chunks, and creating a job for each chunk to scan.

# Define the range of ports to scan
$startPort = 1
$endPort = 65535

# Create an array of ports to scan
$ports = $startPort..$endPort | Get-Random -Count ($endPort - $startPort + 1)

# Define the number of jobs
$jobs = 10

# Read the list of IP addresses from a file
$ipAddresses = Get-Content -Path "IPAddresses.txt"

# Loop through each IP address
foreach ($ip in $ipAddresses) {
    # Create a list of jobs
    $jobList = @()

    # Loop through each job
    for ($i = 0; $i -lt $jobs; $i++) {
        # Split the ports into chunks
        $chunkSize = [Math]::Ceiling(($ports.Count) / $jobs)
        $portChunk = $ports[($i * $chunkSize)..(($i + 1) * $chunkSize - 1)]

        # Create a new job for each chunk of ports
        $job = Start-Job -ScriptBlock {
            param($ip, $portChunk)
            foreach ($port in $portChunk) {
                # Test the connection to the port
                $socket = New-Object System.Net.Sockets.TcpClient
                $socket.SendTimeout = 500
                try {
                    $socket.Connect($ip, $port)
                    if ($socket.Connected) {
                        Write-Output "Port $port is open on $ip"
                    }
                } catch {
                    # Port is closed
                } finally {
                    $socket.Close()
                }
            }
        } -ArgumentList $ip, $portChunk
        $jobList += $job
    }
    # Wait for all jobs to complete
    Wait-Job -Job $jobList
    # Remove the completed jobs
    Remove-Job -Job $jobList
}
