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

# Install Chocolatey
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12
Set-ExecutionPolicy Bypass -Scope Process -Force; Invoke-Expression ((New-Object System.Net.WebClient).DownloadString('https://chocolatey.org/install.ps1'))

# Assign Chocolatey Packages to Install
$Packages = `
    'azd', `
    'azure-cli', `
    'azure-kubelogin', `
    'git', `
    'kubernetes-cli', `
    'kubernetes-helm', `
    'lens',
    'microsoftazurestorageexplorer', `
    'powershell-core', `
    'putty.install', `
    'visualstudiocode', `
    'vscode-powershell'

# Install Chocolatey Packages
ForEach ($PackageName in $Packages)
{ choco install $PackageName -y }

# Create the directory C:\git if it doesn't exist
$gitDirectory = "C:\git"

if (-not (Test-Path -Path $gitDirectory)) {
    New-Item -ItemType Directory -Path $gitDirectory
}

# Navigate to the C:\git directory
Set-Location -Path $gitDirectory

# Clone the repository into C:\git
$repositoryUrl = "https://github.com/solliancenet/foundationallm.git"
git clone $repositoryUrl