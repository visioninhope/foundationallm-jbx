<#
.SYNOPSIS
This script creates an Azure resource group, a virtual network, and a subnet.

.DESCRIPTION
The script performs the following tasks:
1. Creates an Azure resource group in the specified location.
2. Creates a virtual network within the resource group with the specified address prefix.
3. Creates a subnet within the virtual network with the specified address prefix.

.PARAMETER resourceGroupName
The name of the resource group to create.

.PARAMETER location
The Azure region where the resource group and virtual network will be created.

.PARAMETER vnetName
The name of the virtual network to create.

.PARAMETER vnetAddressPrefix
The address prefix for the virtual network.

.PARAMETER subnetName
The name of the subnet to create within the virtual network.

.PARAMETER subnetAddressPrefix
The address prefix for the subnet.

.EXAMPLE
.\Deploy-JbxVnet.ps1
This example runs the script and creates the resource group, virtual network, and subnet with the specified parameters.

.NOTES
Author: Reid Patrick
Date: December 2024
#>

# Define variables
$resourceGroupName = "rg-fllm-jbx"
$location = "EastUS2"
$vnetName = "vnet-fllm-jbx"
$vnetAddressPrefix = "192.168.0.0/24"
$subnetName = "jbx"
$subnetAddressPrefix = "192.168.0.0/28"

# Create the resource group
Write-Host "Creating resource group: $resourceGroupName in location: $location"
az group create --name $resourceGroupName --location $location

# Create the virtual network
Write-Host "Creating virtual network: $vnetName with address prefix: $vnetAddressPrefix"
az network vnet create `
	--resource-group $resourceGroupName `
	--name $vnetName `
	--address-prefix $vnetAddressPrefix `
	--location $location

# Create the subnet
Write-Host "Creating subnet: $subnetName with address prefix: $subnetAddressPrefix in virtual network: $vnetName"
az network vnet subnet create `
	--resource-group $resourceGroupName `
	--vnet-name $vnetName `
	--name $subnetName `
	--address-prefix $subnetAddressPrefix

Write-Host "Resource group, virtual network, and subnet creation completed successfully."