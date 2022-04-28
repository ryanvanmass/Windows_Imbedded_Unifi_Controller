# Key Features
* Easily Install the Ubiquiti Unifi Controller under a dedicated Service account
* View the Controller Log in realtime
* Easily set the Controller software to run as a windows service

# Validated versions of Windows
* 10
* 11
* 2022 Datacenter Core (With FOD Installed)

# Setup
__Pre-compiled Executable__
1. Run the executable as an Admin
2. Select Desired Configuration Option
3. Follow onscreen prompts

# Compiling your own executable
1. Run the bellow commands in an administrative powershell window
```
Install-Module ps2exe
Import-Module ps2exe
```
2. Run `win-ps2exe` in an administrative powershell window
3. Enter the bellow information and select compile
   * Source: Directory to `Setup.ps1`
   * Destination: Select where you would like the executable saved
   * Deselect compile as a graphical app
   * Select Run with administrative privleges