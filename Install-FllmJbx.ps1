<#
.SYNOPSIS
This script sets up a development environment by expanding the C: drive, installing Chocolatey and various packages, cloning a GitHub repository, and enabling necessary Windows features.

.DESCRIPTION
The script performs the following actions:
1. Sets debug settings and starts a transcript of the script output.
2. Expands the C: drive to use all available space.
3. Installs Chocolatey.
4. Installs a list of specified Chocolatey packages.
5. Clones the FoundationaLLM repository from GitHub.
6. Enables the Hyper-V feature.
7. Enables the Windows Subsystem for Linux (WSL) feature.
8. Enables the Virtual Machine Platform feature required for WSL2.
9. Stops the transcript and restarts the computer to apply changes.

.PARAMETER None
This script does not take any parameters.

.NOTES
File Name: Install-FllmJbx.ps1
Author: Reid Patrick
Date: December 2024
Version: 1.0

.EXAMPLE
.\Install-FllmJbx.ps1
This command runs the script to set up the development environment.

#>

# Set Debug settings and start a transcript of the script output
$ErrorActionPreference = "SilentlyContinue"
Set-StrictMode -Version Latest

# Expand C: drive to use all available space
$MaxSize = (Get-PartitionSupportedSize -DriveLetter C).SizeMax
Resize-Partition -DriveLetter C -Size $MaxSize

# Install Chocolatey
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Assign Chocolatey Packages and Versions
# Specify the package name as the key and the version as the value (use 'latest' for the latest version)
$Packages = [ordered]@{
    'azd'                           = 'latest'
    'azure-cli'                     = 'latest'
    'azure-kubelogin'               = 'latest'
    'azcopy10'                      = 'latest'
    'docker-desktop'                = 'latest'
    'filezilla'                     = 'latest'
    'git'                           = 'latest'
    'kubernetes-cli'                = 'latest'
    'kubernetes-helm'               = 'latest'
    'lens'                          = 'latest'
    'microsoftazurestorageexplorer' = 'latest'
    'powershell-core'               = '7.4.6'
    'visualstudiocode'              = 'latest'
    'vscode-powershell'             = 'latest'
    'vscode-csharp'                 = 'latest'
    'visualstudio2022professional'  = 'latest'
}

# Install Chocolatey Packages with version support
foreach ($PackageName in $Packages.Keys) {
    $Version = $Packages[$PackageName]
    if ($Version -ne 'latest') {
        choco install --ignore-checksums --no-progress $PackageName --version $Version -y
    }
    else {
        choco install --ignore-checksums --no-progress $PackageName -y
    }
}

# Configure Azure CLI extension for dynamic install
az config set extension.dynamic_install_allow_preview=true

# Add FLLMAdmin user to the docker-users group
# Define the user and group names
$UserName = "fllmadmin"
$GroupName = "docker-users"

# Check if the group exists
$Group = Get-LocalGroup -Name $GroupName -ErrorAction SilentlyContinue
if (-not $Group) {
    Write-Host "Group '$GroupName' does not exist. Exiting..." -ForegroundColor Red
    exit 1
}

# Check if the user exists
$User = Get-LocalUser -Name $UserName -ErrorAction SilentlyContinue
if (-not $User) {
    Write-Host "User '$UserName' does not exist. Exiting..." -ForegroundColor Red
    exit 1
}

# Add the user to the group
try {
    Add-LocalGroupMember -Group $GroupName -Member $UserName
    Write-Host "User '$UserName' has been added to the '$GroupName' group." -ForegroundColor Green
}
catch {
    Write-Host "Failed to add user '$UserName' to the '$GroupName' group. Error: $_" -ForegroundColor Red
}

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
Restart-Computer -Force
