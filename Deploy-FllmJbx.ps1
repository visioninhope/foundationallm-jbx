<#
.SYNOPSIS
    Deploys an Azure VM configured to perform foundationallm via a Bicep template and PowerShell script.

.DESCRIPTION
    This script automates the deployment of a pre-configured Azure VM which can be used to perform foundationallm tasks.
    All the necessary resources are created using a Bicep template, and the script prompts for the admin password to be set on the VM.
    Please hard-code the other parameters in the script or pass them as arguments when running the script.

.PARAMETER adminUsername
    The username for the administrator account on the VM. Default is 'fllmadmin'.

.PARAMETER location
    The Azure region where the resources will be deployed. Default is 'eastus2'.

.PARAMETER nsgName
    The name of the Network Security Group (NSG). Default is 'fllm-jbx-nsg'.

.PARAMETER publicIpName
    The name of the Public IP address associated with the VM. Default is 'fllm-jbx-pip'.

.PARAMETER resourceGroupName
    The name of the Resource Group in which the resources will be deployed. Default is 'rg-dnstest'.

.PARAMETER subnetName
    The name of the Subnet within the Virtual Network (VNet). Default is 'jbx'.

.PARAMETER vmName
    The name of the Virtual Machine to be deployed. Default is 'fllm-jbx-vm'.

.PARAMETER vnetName
    The name of the Virtual Network (VNet) where the Subnet is located. Default is 'vnet-fllm'.

.PARAMETER vnetRgName
    The name of the Resource Group where the Virtual Network (VNet) is located. Default is 'rg-vnet'.

.EXAMPLE
    ./Deploy-FllmJbx.ps1 -adminUsername "adminuser" -location "westus2" -nsgName "nsg-myproject" -publicIpName "pip-myproject" -resourceGroupName "rg-myproject" -subnetName "subnet1" -vmName "vm-myproject" -vnetName "vnet-myproject" -vnetRgName "rg-myvnet"
    This example runs the script to deploy an infrastructure in the 'westus2' region with a custom admin username, resource names, and a specified VNet resource group.

.NOTES
    Version: 1.0
    Author: Dan Patrick
    This script is intended for deploying infrastructure for the 'foundationallm' project.
#>

param (
    [Parameter(Mandatory = $false)][string]$adminUsername = "fllmadmin",
    [Parameter(Mandatory = $false)][string]$location = "eastus2",
    [Parameter(Mandatory = $false)][string]$nsgName = "nsg-vm-fllm-jbx",
    [Parameter(Mandatory = $false)][string]$publicIpName = "pip-vm-fllm-jbx",
    [Parameter(Mandatory = $false)][string]$resourceGroupName = "rg-fllm-jbx",
    [Parameter(Mandatory = $false)][string]$subnetName = "jbx",
    [Parameter(Mandatory = $false)][string]$vmName = "vm-fllm-jbx",
    [Parameter(Mandatory = $false)][string]$vnetName = "vnet-fllm-jbx",
    [Parameter(Mandatory = $false)][string]$vnetRgName = "rg-fllm-jbx"
)

# Prompt for the admin password
$adminPassword = Read-Host -Prompt "Enter the Admin Password" -AsSecureString

# Convert the secure password to a plain text string (required for deployment)
$adminPasswordPlainText = ConvertTo-SecureString $adminPassword -AsPlainText -Force

# Get the Internet facing IP address of the deployment machine
$allowedRdpSourceIp = Invoke-RestMethod -Uri "https://api.ipify.org"

# Get the VNet ID using the az cli
$vnetId = az network vnet show --resource-group $vnetRgName --name $vnetName --query id --output tsv

# Check if the VNet ID was retrieved successfully
if (-not $vnetId) {
    Write-Error "Failed to retrieve VNet ID. Please ensure the VNet exists in the specified resource group."
    exit 1
}

# Set the deployment parameters
$parameters = @"
{
    "adminUsername": {
        "value": "$adminUsername"
    },
    "adminPassword": {
        "value": "$adminPasswordPlainText"
    },
    "allowedRdpSourceIp": {
        "value": "$allowedRdpSourceIp"
    },
    "location": {
        "value": "$location"
    },
    "nsgName": {
        "value": "$nsgName"
    },
    "publicIpName": {
        "value": "$publicIpName"
    },
    "subnetName": {
        "value": "$subnetName"
    },
    "vmName": {
        "value": "$vmName"
    },
    "vnetId": {
        "value": "$vnetId"
    },
    "vnetRgName": {
        "value": "$vnetRgName"
    } 
}
"@

# Define the path to your Bicep file
$bicepFilePath = "main.bicep" # Update this with the correct path

# Create the resource group if it doesn't exist
$rgExists = az group exists --name $resourceGroupName
if (-not $rgExists) {
    az group create --name $resourceGroupName --location $location
}

# Save the parameters JSON to a temporary file
$parametersFilePath = [System.IO.Path]::GetTempFileName() + ".json"
$parameters | Out-File -FilePath $parametersFilePath -Encoding utf8

# Deploy the Bicep template using az cli
az deployment group create `
    --parameters @$parametersFilePath `
    --resource-group $resourceGroupName `
    --template-file $bicepFilePath `
    --verbose

# Clean up the temporary parameters file
Remove-Item $parametersFilePath