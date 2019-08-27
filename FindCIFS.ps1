# Query AD for CIFS SPNs

$search = New-Object DirectoryServices.DirectorySearcher([ADSI]"")
$search.filter = "(servicePrincipalName=cifs/*)"

## You can use this to filter for OU's:
## $results = $search.Findall() | ?{ $_.path -like '*OU=whatever,DC=whatever,DC=whatever*' }
$results = $search.Findall()

foreach( $result in $results ) {
	$userEntry = $result.GetDirectoryEntry()
	Write-host "Object Name = " $userEntry.name 


	#$i=1
	#foreach( $SPN in $userEntry.servicePrincipalName ) {
	#	Write-host "SPN(" $i ")   =      " $SPN 
	#	$i+=1
	#}
	Write-host "" 
}  out-file C:\temp\CIFS.txt -Append
