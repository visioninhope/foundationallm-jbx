<#
.SYNOPSIS
    Installs Chocolatey and a predefined list of packages, then creates a directory and clones a Git repository.

.DESCRIPTION
    This script installs Chocolatey on the system and uses it to install a list of packages essential for development and administration tasks.
    After installing the packages, the script creates a directory `C:\git` and clones the specified Git repository into that directory.
    This script assumes that Git is among the installed packages and that the system has access to the internet to perform the installations.

.PARAMETER None
    This script does not take any parameters. All operations are performed in sequence as defined within the script.

.EXAMPLE
    ./Install-FllmJbx.ps1
    This example shows how to run the script without any parameters. It will install Chocolatey, install the listed packages, create a directory `C:\git`, and clone the repository.

.NOTES
    This script is run as a custom script extension on an Azure VM. It is intended to be used as part of a larger deployment script.
#>
$ErrorActionPreference = "silentlycontinue"
# Start a transcript of the script output
Start-Transcript -Path "C:\Install-FllmJbx.log"

# Expand C: drive to use all available space
$MaxSize = (Get-PartitionSupportedSize -DriveLetter C).SizeMax
Resize-Partition -DriveLetter C -Size $MaxSize

# Install Chocolatey
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Assign Chocolatey Packages to Install
$Packages = `
    'azd', `
    'azure-cli', `
    'azure-kubelogin', `
    'azcopy10', `
    'git', `
    'gitkraken', `
    'kubernetes-cli', `
    'kubernetes-helm', `
    'lens', `
    'microsoftazurestorageexplorer', `
    'powershell-core', `
    'visualstudiocode', `
    'vscode-powershell', `
    'docker-desktop', `
    'filezilla', `
    'visualstudio2022professional', `
    'dotnet', `
    'dotnet-sdk', `
    'vscode-csharp'

# Install Chocolatey Packages
ForEach ($PackageName in $Packages)
{ choco install --ignore-checksums $PackageName -y }

# Clone the FoundationaLLM repo
$repoDir = "C:\foundationallm"
$env:PATH += "C:\Program Files\Git\cmd"
git clone https://github.com/solliancenet/foundationallm.git $repoDir

# Enable the Hyper-V feature
Write-Host "Enabling Hyper-V..."
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Hyper-V -All -NoRestart

# Enable Windows Subsystem for Linux (WSL) feature
Write-Host "Enabling WSL..."
Enable-WindowsOptionalFeature -Online -FeatureName Microsoft-Windows-Subsystem-Linux -NoRestart

# Enable Virtual Machine Platform (required for WSL2)
Write-Host "Enabling Virtual Machine Platform..."
Enable-WindowsOptionalFeature -Online -FeatureName VirtualMachinePlatform -NoRestart

# Stopping the Transcript and restarting the computer to apply changes
Write-Host "The system will now restart to apply changes."
Stop-Transcript
Restart-Computer -Force
