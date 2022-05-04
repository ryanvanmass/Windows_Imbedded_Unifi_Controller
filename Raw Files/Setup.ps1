### User Selects Function ###
Write-Output "Please Select one of the FOllowing"
Write-Output "1. Install Controller"
Write-Output "2. Enable Running the Controller as a service"
Write-Output "3. Live Log monitor"
# Write-Output "4. Prep for Upgrade"

$env:usernameSelection = Read-Host -Prompt "Selection: "

### Install Controller ###
if ($env:usernameSelection -eq 1) {
    # Prompts user if they want to create a Service account
    Write-Output "Would you like to create a Service Account to run the Controller on? (Y/N)"
    Write-Output "Note: Service account only currently works on Windows Server Core"
    
    $ServiceAccount = Read-Host -Prompt "Selection: "
    
    if ($ServiceAccount -eq "Y") {
        # Create "Service" User Account
        Write-Output 'Please Enter a password for the Controller "Service" Account'
        $Password = Read-Host -AsSecureString
            
        New-localUser -Name Controller -Password $Password -PasswordNeverExpires
        Add-LocalGroupMember Users Controller
        
        Write-Output "Please Enter the Controller Account Password and press Enter"
        runas /savecred /user:Controller whoami


        # Install Java
        Write-Output "Downloading Java"
        Invoke-WebRequest https://javadl.oracle.com/webapps/download/AutoDL?BundleId=245807_df5ad55fdd604472a86a45a217032c7d -OutFile C:\Users\Controller\Downloads\Java.exe 

        Write-Output "Installing Java"
        C:\Users\Controller\Downloads\Java.exe /s
        Start-Sleep 120

        # Install Unifi Controller
        Write-Output "Downloading Unifi Controller"
        Invoke-WebRequest https://dl.ui.com/unifi/7.0.25/UniFi-installer.exe -OutFile C:\Users\Controller\Downloads\UniFi-installer.exe

        Set-Location C:\Users\Controller\Downloads
        
        Write-Output "Please Install Unifi Controller (It may take a few moments for the installer to launch)"
        runas /savecred /user:Controller UniFi-installer.exe
        Pause

        # Get Current IP Address
        $IP = (Get-WmiObject -class win32_NetworkAdapterConfiguration -Filter 'ipenabled = "true"').ipaddress[0]
        [Environment]::SetEnvironmentVariable("IPAddress", $ip, "User")

        # Forward Port 8443 to 443
        Write-Output "Forwarding Port 8443 to 443"
        netsh interface portproxy add v4tov4 listenaddress=$IP listenport=443 connectaddress=$IP connectport=8443
        netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=443 connectaddress=127.0.0.1 connectport=8443

        Write-Output "Controller is Now Installed"
        Pause
        Exit
    }
    elseif ($ServiceAccount -eq "N") {
        # Install Java
        Write-Output "Downloading Java"
        Invoke-WebRequest https://javadl.oracle.com/webapps/download/AutoDL?BundleId=245807_df5ad55fdd604472a86a45a217032c7d -OutFile Java.exe 
        
        Write-Output "Installing Java"
        .\Java.exe /s
        Start-Sleep 120
        Move-Item Java.exe C:\Users\$env:username\Downloads\Java.exe

        # Install Unifi Controller
        Write-Output "Downloading Unifi Controller"
        Invoke-WebRequest https://dl.ui.com/unifi/7.0.25/UniFi-installer.exe -OutFile UniFi-installer.exe
                
        Write-Output "Please Install Unifi Controller (It may take a few moments for the installer to launch)"
        .\UniFi-installer.exe
        Pause

        Move-Item UniFi-installer.exe C:\Users\$env:username\Downloads\UniFi-installer.exe
        
        # Get Current IP Address
        $IP = (Get-WmiObject -class win32_NetworkAdapterConfiguration -Filter 'ipenabled = "true"').ipaddress[0]
        [Environment]::SetEnvironmentVariable("IPAddress", $ip, "User")
        
        # Forward Port 8443 to 443
        Write-Output "Forwarding Port 8443 to 443"
        netsh interface portproxy add v4tov4 listenaddress=$IP listenport=443 connectaddress=$IP connectport=8443
        netsh interface portproxy add v4tov4 listenaddress=127.0.0.1 listenport=443 connectaddress=127.0.0.1 connectport=8443
        
        Write-Output "Controller is Now Installed"
        Pause
        Exit
    }
    
    
    
    
    
    
    

}

### Enable Running Controller as a Service ###
elseif ($env:usernameSelection -eq 2) {
    $ServiceAccount = Read-Host -Prompt "Are you Using a Service account (Y/N):"

    if ($ServiceAccount -eq "Y") {
        Set-Location 'C:\Users\Controller\Ubiquiti UniFi'
        # Kill Unifi if it is running
        Stop-Process -Name Java*
    
        # Add Unifi Service
        Write-Output "Installing Controller as a Service"
        java -jar 'C:\Users\Controller\Ubiquiti UniFi\lib\ace.jar' installsvc

        # Start Service
        Start-Service Unifi

        Pause
        Exit
    }
    elseif ($ServiceAccount -eq "N") {
        # Kill Unifi if it is running
        Stop-Process -Name Java*

        Set-Location "C:\Users\$env:username\Ubiquiti UniFi\lib"
        java -jar ace.jar installsvc

        # Start Service
        Start-Service Unifi

        Pause
        Exit        
    }
}

### Live Log Monitor ###
elseif ($env:usernameSelection -eq 3) {
    Get-Content -Tail 30 "C:\Users\Controller\Ubiquiti UniFi\logs\server.log" -Wait
}

