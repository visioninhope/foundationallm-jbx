# FoundationaLLM-JBX

Welcome to the **FoundationaLLM-JBX** repository! This project is designed for the deployment of the **FoundationaLLM** product, which is available in a separate repository. To learn more about the FoundationaLLM project, please visit the [FoundationaLLM GitHub repository](https://github.com/solliancenet/FoundationaLLM) and the official documentation at [docs.FoundationaLLM.ai](https://docs.FoundationaLLM.ai/).

## Table of Contents

- [FoundationaLLM-JBX](#foundationallm-jbx)
  - [Table of Contents](#table-of-contents)
  - [Project Overview](#project-overview)
  - [Features](#features)
    - [Prerequisites](#prerequisites)
    - [Installation](#installation)

## Project Overview

FoundationaLLM-JBX is a deployment template designed to streamline the process of setting up and managing the FoundationaLLM environment in Azure. This template is a complementary resource to the main FoundationaLLM project, providing the necessary infrastructure and automation scripts for efficient deployment.

## Features

- **FLLM Installation Jumpbox**: Rapidly deploy a jumpbox environment for installing and configuring the FoundationaLLM product.
- **Tool Installation**: The `install-FllmJbx.ps1` script automates the installation of essential tools, including:
  - **Chocolatey**: Package manager for Windows.
  - **Azure CLI**: Command-line interface for managing Azure resources.
  - **Azure Developer CLI (azd)**: CLI tool to streamline Azure development.
  - **Azure Storage Explorer**: Tool for managing Azure storage resources.
  - **Git**: Version control system.
  - **Helm**: Kubernetes package manager.
  - **Kubectl**: Command-line tool for interacting with Kubernetes clusters.
  - **Lens**: Kubernetes IDE.
  - **PowerShell Core**: Cross-platform task automation tool.
  - **Putty**: SSH and telnet client.
  - **Visual Studio Code**: Visual Studio Code editor.
  - **VSCode PowerShell Extension**: PowerShell extension for Visual Studio Code.

### Prerequisites

Before you begin, ensure you have met the following requirements:

- [Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli) installed on your machine.
- Sign in to Azure using the Azure CLI by running `az login`.
- Set the subscription you want to use by running `az account set --subscription <subscription-id>`.
- [Git](https://git-scm.com/downloads) installed on your local machine.
- [Powershell Core](https://learn.microsoft.com/powershell/scripting/install/installing-powershell?view=powershell-7.4) installed on your local machine.

### Installation

1. Clone this repository:

   ```bash
   git clone https://github.com/solliancenet/FoundationaLLM-jbx.git
   cd FoundationaLLM-jbx

1. Collect the following information:
   1. **Resource Group Name**: The name of the resource group where the jumpbox will be deployed.
   1. **Location**: The Azure region where the jumpbox will be deployed (e.g., `eastus2`) must be the same region as the Virtual Network.
   1. **VNet Name**: The name of the virtual network.
   1. **Subnet Name**: The name of the subnet.

[!NOTE:] The following parameters are optional and can be modified in the `Deploy-FllmJbx.ps1` script:
   ```powershell
    [Parameter(Mandatory = $false)][string]$adminUsername = "fllmadmin",
    [Parameter(Mandatory = $false)][string]$location = "eastus2",
    [Parameter(Mandatory = $false)][string]$nsgName = "fllm-jbx-nsg",
    [Parameter(Mandatory = $false)][string]$publicIpName = "fllm-jbx-pip",
    [Parameter(Mandatory = $false)][string]$resourceGroupName = "rg-dnstest",
    [Parameter(Mandatory = $false)][string]$subnetName = "jbx",
    [Parameter(Mandatory = $false)][string]$vmName = "fllm-jbx-vm",
    [Parameter(Mandatory = $false)][string]$vnetName = "vnet-fllm"

1. Run the `Deploy-FllmJbx.ps1` script:

   ```powershell
   .\Deploy-FllmJbx.ps1 -resourceGroupName <resource-group-name> -location <azure-region> -vnetName <vnet-name> -subnetName <subnet-name>
   