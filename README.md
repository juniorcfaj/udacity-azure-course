# Azure Infrastructure Operations Project: Deploying a scalable IaaS web server in Azure

### Introduction

This project is for Azure DevOps Engineers who want to deploy a scalable IaaS web server in Azure.

### Getting Started
1. Clone this repository

2. Log in into Azure

3. Update this README to reflect how someone would use your code.

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

### Instructions

#### Login into Azure

    az login

#### Creating a Policy
    # Create the Policy Definition (Subscription scope)
    az policy definition create --name tagging-policy --rules https://raw.githubusercontent.com/juniorcfaj/udacity-azure-course/main/azurepolicy.rules.json

    # Create the Policy Assignment
    # Set the scope to a resource group; may also be a subscription or management group
    az policy assignment create --name tagging-policy --display-name 'Tagging Policy' --scope /subscriptions/xxxxxxxxxxxxxxxxxxxxxxxx --policy tagging-policy

    # Show your Policy
    az policy assignment show tagging-policy

#### Create a Resource Group

    # Run the command
    az group create -n udacity-project -l eastus

#### Getting your informations from Azure

    # Client_id, Client_secret, Tenant_id
    az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
    # Subscription
    az account show --query "{ subscription_id: id }"

### Build the image with Packer

Now you have all informations about your Azure account that you need. Use "client_id", "client_secret", "tenant_id" e "subscription_id" into variables on server.json and you'll be able to build your image using Packer.

    # Run the command:
    packer build server.json

## Create a Terraform template

    # First you need to update your Terraform. Run the command:
    terraform init

    # Plannig your Terraform template. Run the command:
    terraform plan -out main.tf

    # If your template is right, you can apply with this command
    terraform apply

### Output

Creating Policy

    {
        "description": null,
        "displayName": "Tagging Policy",
        "enforcementMode": "Default",
        "id": "/subscriptions/XXXXXXXXXXXXXXXXXXXXXXX/providers/Microsoft.Authorization/policyAssignments/tagging-policy",
        "identity": null,
        "location": null,
        "metadata": {
        "createdBy": "XXXXXXXXXXXXXXXXXXXXXXXXXXX",
        "createdOn": "2021-11-01T18:39:45.0906256Z",
        "updatedBy": null,
        "updatedOn": null
        },
        "name": "tagging-policy",
        "nonComplianceMessages": null,
        "notScopes": null,
        "parameters": null,
        "policyDefinitionId": "/subscriptions/XXXXXXXXXXXXXXXXXXXXXXX/providers/Microsoft.Authorization/policyDefinitions/tagging-policy",
        "scope": "/subscriptions/XXXXXXXXXXXXXXXXXXXXXXX",
        "type": "Microsoft.Authorization/policyAssignments"
    }

