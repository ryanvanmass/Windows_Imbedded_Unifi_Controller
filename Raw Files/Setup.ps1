### User Selects Function ###
Write-Output "Please Select one of the FOllowing"
Write-Output "1. Install Controller"
Write-Output "2. Enable Running the Controller as a service"
Write-Output "3. Live Log monitor"
# Write-Output "4. Prep for Upgrade"

$UserSelection = Read-Host -Prompt "Selection: "

### Install Controller ###
if ($UserSelection -eq 1) {
    # Create "Service" User Account
    Write-Output 'Please Enter a password for the Controller "Service" Account'
    $Password = Read-Host -AsSecureString

    New-localUser -Name Controller -Password $Password -PasswordNeverExpires
    Add-LocalGroupMember Users Controller

    $Credentials = Get-Credential -UserName Controller -Message "Please Enter Controller Service Account Password"

    Start whoami -Credential $Credentials


    # Install Java
    Write-Output "Downloading Java"
    Invoke-WebRequest https://javadl.oracle.com/webapps/download/AutoDL?BundleId=245807_df5ad55fdd604472a86a45a217032c7d -OutFile C:\Users\Controller\Downloads\Java.exe 

    Write-Output "Installing Java"
    C:\Users\Controller\Downloads\Java.exe /s
    Start-Sleep 120

    # Install Unifi Controller
    Write-Output "Downloading Unifi Controller"
    Invoke-WebRequest https://dl.ui.com/unifi/7.0.25/UniFi-installer.exe -OutFile C:\Users\Controller\Downloads\UniFi-installer.exe

    Write-Output "Please Install Unifi Controller"
    Start-Process C:\Users\Controller\Downloads\UniFi-installer.exe -Credential $Credentials
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
elseif ($UserSelection -eq 2) {
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
elseif ($UserSelection -eq 3) {
    Get-Content -Tail 30 "C:\Users\Controller\Ubiquiti UniFi\logs\server.log" -Wait
}

