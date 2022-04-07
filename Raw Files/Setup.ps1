# Install Java
Write-Output "Downloading Java"
Invoke-WebRequest https://javadl.oracle.com/webapps/download/AutoDL?BundleId=245807_df5ad55fdd604472a86a45a217032c7d -OutFile C:\Users\Ryan\Downloads\Java.exe 

Write-Output "Installing Java"
C:\Users\Ryan\Downloads\Java.exe /s
Start-Sleep 120

# Install Unifi Controller
Write-Output "Downloading Unifi Controller"
Invoke-WebRequest https://dl.ui.com/unifi/7.0.25/UniFi-installer.exe -OutFile C:\Users\Ryan\Downloads\UniFi-installer.exe

Write-Output "Please Install Unifi Controller"
C:\Users\Ryan\Downloads\UniFi-installer.exe
Pause

#Add Unifi Service
Write-Output "Installing Controller as a Service"
java -jar 'C:\Users\Ryan\Ubiquiti UniFilib\ace.jar' installsvc

# Gets Current IP for Port Forward
$IP = (Get-WmiObject -class win32_NetworkAdapterConfiguration -Filter 'ipenabled = "true"').ipaddress[0]
[Environment]::SetEnvironmentVariable("IPAddress", $ip, "User")

#Forward Port 8443 to 443
Write-Output "Forwarding Port 8443 to 443"
netsh interface portproxy add v4tov4 listenaddress=$IP listenport=443 connectaddress=$IP connectport=8443

Pause