<#
.SYNOPSIS
Checks the versions of required tools for the installation of FoundationaLLM.

.DESCRIPTION
This script verifies if the installed versions of various tools meet the minimum required versions for the installation of FoundationaLLM. 
It checks the versions of Azure CLI, Docker, Git, Helm, Kubectl, Kubelogin, and PowerShell. If any tool does not meet the minimum version requirement, 
the script will output a report indicating which tools need to be updated and will exit with an error code.

.PARAMETER minVersions
A hashtable defining the minimum required versions for each tool.

.FUNCTIONS
Check-Version
	Compares the current version of a tool with the minimum required version.

.NOTES
Author: Dan Patrick
Date: October 2023

.EXAMPLE
.\Check-FllmJbxTools.ps1
	Runs the script and checks the versions of the required tools. Outputs a report indicating whether each tool meets the minimum version requirement.
#>

Set-PSDebug -Trace 0 # Echo every command (0 to disable, 1 to enable, 2 to enable verbose)
Set-StrictMode -Version 3.0
$ErrorActionPreference = "Stop"

# Define minimum versions
$minVersions = @{
	"Azd"        = "1.11.1"
	"AzureCLI"   = "2.58.0"
	"Docker"     = "27.4.0"
	"Git"        = "2.48.0"
	"Helm"       = "3.0.0"
	"Kubectl"    = "1.30.0"
	"Kubelogin"  = "0.1.0"
	"PowerShell" = "7.4.6"
}

# Function to check version
function Check-Version {
	param (
		[string]$currentVersion,
		[string]$minVersion
	)

	$current = [Version]$currentVersion
	$minimum = [Version]$minVersion

	if ($current -lt $minimum) {
		return $false
	}

	return $true
}

# Initialize a report and a flag for overall requirements
$report = @()
$allRequirementsMet = $true

# Define ANSI escape codes for colors
$greenColor = "`e[32m"
$redColor = "`e[31m"
$resetColor = "`e[0m"

# Define Unicode characters for check mark and X
$checkMark = "$greenColor" + [char]::ConvertFromUtf32(0x2714) + "$resetColor"
$redX = "$redColor" + [char]::ConvertFromUtf32(0x2718) + "$resetColor"

# Message to user about the check
Write-Host -ForegroundColor Blue "Checking required minimums of tools required for the Installation of FoundationaLLM..."

# Check for Azure CLI
$azureCliVersion = az --version 2>$null
if ($azureCliVersion) {
	$versionLine = ($azureCliVersion -split "\r?\n" | Select-String -Pattern "^azure-cli ")
	if ($versionLine) {
		$version = ($versionLine -replace "azure-cli", "" -replace "[^\d.]", "").Trim()
		$isVersionOk = Check-Version $version $minVersions["AzureCLI"]
		if ($isVersionOk) {
			$report += "Azure CLI: $version (minimum required: $($minVersions["AzureCLI"])) $checkMark"
		}
		else {
			$report += "Azure CLI: $version (minimum required: $($minVersions["AzureCLI"])) $redX"
			$allRequirementsMet = $false
		}
	}
 else {
		$report += "Azure CLI: Version not found $redX"
		$allRequirementsMet = $false
	}
}
else {
	$report += "Azure CLI: Not installed $redX"
	$allRequirementsMet = $false
}

# Check for Docker
$dockerVersion = docker --version 2>$null
if ($dockerVersion) {
	$match = $dockerVersion | Select-String -Pattern "Docker version (\d+\.\d+\.\d+)"
	if ($match) {
		$version = $match.Matches[0].Groups[1].Value
		$isVersionOk = Check-Version $version $minVersions["Docker"]
		if ($isVersionOk) {
			$report += "Docker: $version (minimum required: $($minVersions["Docker"])) $checkMark"
		}
		else {
			$report += "Docker: $version (minimum required: $($minVersions["Docker"])) $redX"
			$allRequirementsMet = $false
		}
	}
 else {
		$report += "Docker: Version not found $redX"
		$allRequirementsMet = $false
	}
}
else {
	$report += "Docker: Not installed $redX"
	$allRequirementsMet = $false
}

# Check for Git
$gitVersion = git --version 2>$null
if ($gitVersion) {
	$match = $gitVersion | Select-String -Pattern "git version (\d+\.\d+\.\d+)"
	if ($match) {
		$version = $match.Matches[0].Groups[1].Value
		$isVersionOk = Check-Version $version $minVersions["Git"]
		if ($isVersionOk) {
			$report += "Git: $version (minimum required: $($minVersions["Git"])) $checkMark"
		}
		else {
			$report += "Git: $version (minimum required: $($minVersions["Git"])) $redX"
			$allRequirementsMet = $false
		}
	}
 else {
		$report += "Git: Version not found $redX"
		$allRequirementsMet = $false
	}
}
else {
	$report += "Git: Not installed $redX"
	$allRequirementsMet = $false
}

# Check for Helm
$helmVersion = helm version --short --client 2>$null
if ($helmVersion) {
	$version = ($helmVersion -replace "v", "") -replace "([^\d\.]+).*", ""
	$isVersionOk = Check-Version $version $minVersions["Helm"]
	if ($isVersionOk) {
		$report += "Helm: $version (minimum required: $($minVersions["Helm"])) $checkMark"
	}
 else {
		$report += "Helm: $version (minimum required: $($minVersions["Helm"])) $redX"
		$allRequirementsMet = $false
	}
}
else {
	$report += "Helm: Not installed $redX"
	$allRequirementsMet = $false
}

# Check for Kubectl
$kubectlVersion = kubectl version --client --output=json 2>$null
if ($kubectlVersion) {
	$version = ($kubectlVersion | ConvertFrom-Json).clientVersion.gitVersion -replace "v", "" -replace "[^0-9.].*", ""
	$isVersionOk = Check-Version $version $minVersions["Kubectl"]
	if ($isVersionOk) {
		$report += "Kubectl: $version (minimum required: $($minVersions["Kubectl"])) $checkMark"
	}
 else {
		$report += "Kubectl: $version (minimum required: $($minVersions["Kubectl"])) $redX"
		$allRequirementsMet = $false
	}
}
else {
	$report += "Kubectl: Not installed $redX"
	$allRequirementsMet = $false
}

# Check for Kubelogin
$kubeloginVersion = kubelogin --version 2>$null
if ($kubeloginVersion) {
	$match = $kubeloginVersion | Select-String -Pattern "git hash: v(\d+\.\d+\.\d+)"
	if ($match) {
		$version = $match.Matches[0].Groups[1].Value -replace "[^0-9.].*", ""
		$isVersionOk = Check-Version $version $minVersions["Kubelogin"]
		if ($isVersionOk) {
			$report += "Kubelogin: $version (minimum required: $($minVersions["Kubelogin"])) $checkMark"
		}
		else {
			$report += "Kubelogin: $version (minimum required: $($minVersions["Kubelogin"])) $redX"
			$allRequirementsMet = $false
		}
	}
 else {
		$report += "Kubelogin: Version not found $redX"
		$allRequirementsMet = $false
	}
}
else {
	$report += "Kubelogin: Not installed $redX"
	$allRequirementsMet = $false
}

# Check for PowerShell
$powershellVersion = $PSVersionTable.PSVersion.ToString()
$isVersionOk = Check-Version $powershellVersion $minVersions["PowerShell"]
if ($isVersionOk) {
	$report += "PowerShell: $powershellVersion (minimum required: $($minVersions["PowerShell"])) $checkMark"
}
else {
	$report += "PowerShell: $powershellVersion (minimum required: $($minVersions["PowerShell"])) $redX"
	$allRequirementsMet = $false
}

# Output the report
$report | ForEach-Object { Write-Output $_ }

if (-not $allRequirementsMet) {
	Write-Host -ForegroundColor Red "Not all requirements are met. Please update the tools listed above."
	exit 1
}

Write-Host -ForegroundColor Green "All requirements are met."