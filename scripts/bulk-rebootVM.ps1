### With the parameter "-force" the servers will be rebooted even if there is still an active user session.

###sample1 for loop  (sequential reboot)


#13.11.2018 Restart a list/array of Servers through Windows Remoting

$server = @(
"Hostname-Server1"
"Hostname-Server2"
"Hostname-Server3"
)


foreach ($server in $server){
    try{
        Restart-Computer -ComputerName $Server -force
        write-host "Reboot OK $server" -ForegroundColor Green
    }catch{
        write-host "Reboot NOT OK $server" -ForegroundColor yellow
          }

}



###sample2   reboot as Job (parallel reboot)

#13.11.2018 Restart a Liste/Array of Servers through Windows Remoting

$server = @(
"Hostname-Server1"
"Hostname-Server2"
"Hostname-Server3"
)


foreach ($server in $server){
Invoke-Command -ComputerName $Server -ScriptBlock {shutdown -r -f -t 1} -AsJob  
}
