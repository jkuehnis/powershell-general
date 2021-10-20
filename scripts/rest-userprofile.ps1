#by J.Kühnis 
#Code Elements of https://gallery.technet.microsoft.com/scriptcenter/Remove-UserProfileps1-871f57c4
#Run with elevated rights
$currentPrincipal = New-Object Security.Principal.WindowsPrincipal( [Security.Principal.WindowsIdentity]::GetCurrent( ) )
if ( -not ($currentPrincipal.IsInRole( [Security.Principal.WindowsBuiltInRole]::Administrator ) ) )
{
    Write-Host "This script must be executed in admin mode." -ForegroundColor Yellow
    Write-Error "This script must be executed in admin mode." -ErrorAction Stop
    Pause
}

Function Reset-LocalUserProfile {

    [CmdletBinding()]
    Param(
        [Parameter(Mandatory = $true)][string]$Username,
        [Parameter(Mandatory = $true)][string]$ComputerName,
        [switch]$IncludeSpecialUsers = $False,
        [switch]$Force = $True,
        [bool]$Wildcard   
)

    IF ($Username -match '\*'){
        IF($Wildcard){
            Write-Warning "wildcard enabled, deletion for multiple users enabled"

        }Else{
            Write-Warning "Username must be unique without wildcard '*'. If you like to use wildcard, please use '-Widlcard `$true' parameter. "
        return
        

        }
    }
        
    
    $profileFounds = 0

    #Region Functions

    #https://www.petri.com/test-network-connectivity-powershell-test-connection-cmdlet
    Function Test-PSRemoting {
        [cmdletbinding()]
     
        Param(
            [Parameter(Position = 0, Mandatory, HelpMessage = "Enter a computername", ValueFromPipeline)]
            [ValidateNotNullorEmpty()]
            [string]$Computername,
            [System.Management.Automation.Credential()]$Credential = [System.Management.Automation.PSCredential]::Empty
        )
     
        Begin {
            Write-Host -Message "Starting $($MyInvocation.Mycommand)"  
        } #begin
     
        Process {
            Write-Host -Message "Testing $computername"
            Try {
                $r = Test-WSMan -ComputerName $Computername -Credential $Credential -Authentication Default -ErrorAction Stop
                $True 
            }
            Catch {
                Write-Host $_.Exception.Message
                $False
     
            }
     
        } #Process
     
        End {
            Write-Host -Message "Ending $($MyInvocation.Mycommand)"
        } #end
     
    } #close function

    #Check IF WinRM is OK

    IF (!(Test-PSRemoting -Computername $ComputerName)) {    
        Write-Host -Message "PS Remoting Error, can't reach Connect with WinRM"
        return
        
    }
    

    Try {
        $profiles = Get-WmiObject -Class Win32_UserProfile -Computer $ComputerName -Filter "Special = '$IncludeSpecialUsers'" -EnableAllPrivileges
    }
    Catch {            
        Write-Warning "Failed to retreive user profiles on $ComputerName"
        return
    }

   
    ForEach ($profile in $profiles) {
        try {
            $sid = New-Object System.Security.Principal.SecurityIdentifier($profile.SID)               
            $account = $sid.Translate([System.Security.Principal.NTAccount])    
            $accountName = $account.value.split("\")[1]
            $profilePath = $profile.LocalPath
            $loaded = $profile.Loaded
            $special = $profile.Special
        }
        catch {
            continue
    
        }
            
        If ($accountName.ToLower() -Eq $UserName.ToLower() -Or ($UserName.Contains("*") -And $accountName.ToLower() -Like $UserName.ToLower())) {
      
            #If ($ExcludeUserName -ne [string]::Empty -And -Not $ExcludeUserName.Contains("*") -And ($accountName.ToLower() -eq $ExcludeUserName.ToLower())) {Continue}
            #If ($ExcludeUserName -ne [string]::Empty -And $ExcludeUserName.Contains("*") -And ($accountName.ToLower() -Like $ExcludeUserName.ToLower())) {Continue}

            $profileFounds ++

            If ($profileFounds -gt 1) {Write-Host "`n"}
            Write-Host "Start deleting profile ""$account"" on computer ""$ComputerName"" ..." -ForegroundColor Green
            Write-Host "Account SID: $sid"
            Write-Host "Special system service user: $special"
            Write-Host "Profile Path: $profilePath"
            Write-Host "Loaded : $loaded"
            If ($loaded) {
                Write-Warning "Cannot delete profile because is in use"
                Continue
            }

            If ($Force -Or $PSCmdlet.ShouldProcess($account)) {
                Try {
                    $profile.Delete()           
                    Write-Host "Profile deleted successfully" -ForegroundColor Green        
                }
                Catch {            
                    Write-Host "Error during delete the profile. Maybe the user with you executed the script has no rights or the script was not started with admin rights." -ForegroundColor Red
                }
            } 
        }
    }

    If ($profileFounds -eq 0) {
        Write-Warning "No profiles found on $ComputerName with Name $UserName"
    }
Write-Host '########## START SCRIPT ##########' -ForegroundColor yellow
Reset-LocalUserProfile
}

Reset-LocalUserProfile
