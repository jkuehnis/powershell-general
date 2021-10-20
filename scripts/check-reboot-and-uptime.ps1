#13.11.2018 Restart a Liste/Array of Servers through Windows Remoting

$array = @()
$server = @(
"HostnameServer-1"
"HostnameServer-2"
"HostnameServer-3"
)

foreach ($server in $server){

    IF($s= New-CimSession -ComputerName $server -ErrorAction SilentlyContinue){
        $array += (Get-CimInstance -ClassName win32_operatingsystem -CimSession $s ) #| select csname, lastbootuptime
    }Else{
        $myObject = [PSCustomObject]@{
            PSComputerName     = $server
            csname     = $server
            lastbootuptime = 'no data retrieved'
            }
        $array += $myObject
    }
}

Function Checkreboottime{

Param(
  [Parameter(Mandatory=$true)]
   [int]$time
)


$TimeNow = Get-Date

$array | % {
    IF(!($_.lastbootuptime -eq "no data retrieved")){
        IF ([dateTime]$_.lastbootuptime.AddMinutes($time) -ge $TimeNow){
            write-host $_.csname $_.lastbootuptime -ForegroundColor Green
        }Else{
            write-host $_.csname $_.lastbootuptime -ForegroundColor yellow
        }
    }Else{
        write-host $_.csname $_.lastbootuptime -ForegroundColor Cyan
        }
    }

}
