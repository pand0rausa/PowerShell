import-module C:\Users\<user>\.nuget\SNMP.1.0.0.1\SNMP.psd1
$csv = Import-csv 'C:\temp\snmp.csv'

foreach ($record in $csv){
echo $record.ip $record.alias | out-file c:\temp\SNMP\SNMPresults5.txt -append
Invoke-SnmpWalk -IP $record.ip -Community $record.alias -OIDStart 1.3.6.1.2.1.1 -TimeOut 10000 -Verbose -Version V2U | out-file c:\temp\SNMP\SNMPresults5.txt -append
echo --------------------------------------------------------------------------- | out-file c:\temp\SNMP\SNMPresults5.txt -append
}
