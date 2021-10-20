<#
Certain processes can take a long time. As an example, if you want to search a specific event log trough several servers.
To counteract this, Powershell has introduced “Jobs, Workflows and Foreach-Parallel”. It should be well estimated what you can use where best. Personally, I like to rely on jobs when it comes to remote querying / remote invocation.

I would like to show a small example of how I use Jobs to read out Eventlogs about several machines. In the example, it is only checked if the corresponding log exists or was written in the last 45 minutes. For 128 servers I needed 30 minutes with this parallel Task. I killed the sequential script after 6 hours …
#>


#by J.Kühnis
$Servers = @(
"serverHostname1"
"serverHostname2"
"serverHostname3"
)

Remove-Job *
$outputArray = @()

Foreach ($Server in $Servers){

Start-Job -Name $Server -ArgumentList $Server{
    param($servername)
    IF(Get-EventLog -LogName System -InstanceId '12306' -After (Get-Date).AddMinutes(-45) -ComputerName $servername -ErrorAction Ignore){
    
    Write-Output"$servername  true"
    }Else{
    Write-Output "$servername  false"
    
    }
} 

}

While (Get-Job -State "Running") {
    Clear-Host
    write-host "Jobs Running"  (Get-Job).count
    Start-Sleep 2
}
Clear-Host
Get-Job
write-host "Jobs completed, getting output"

Get-Job | ForEach-Object {
    $a = Receive-Job $_.Id
    $a
    $outputArray += $a
  
}

#Use the variable $outputArray to get or export the Outputdata
