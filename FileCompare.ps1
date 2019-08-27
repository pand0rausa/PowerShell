$File1 = Get-Content 'c:\temp\Users1.txt'
$File2 = Get-Content 'C:\temp\users2.txt'

$Lookup = @{
    "=>" = "Present in File2"
    "<=" = "Present in File1"
    "==" = "Present in both files"
}

Compare-Object -ReferenceObject $File1 -DifferenceObject $File2 -IncludeEqual | Select @{Name="String";Expression={$_.InputObject}},@{Name="Presence";Expression={$Lookup[$_.SideIndicator]}} | Out-GridView
