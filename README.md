# Azure Voting App an AKS using Helm

This sample creates a multi-container application in an Azure Kubernetes Service (AKS) cluster. The application interface has been built using Python / Flask. The data component is using Redis.

To walk through a quick deployment of this application, see the AKS [quick start](https://docs.microsoft.com/en-us/azure/aks/kubernetes-walkthrough?WT.mc_id=none-github-nepeters).

## Deploying infrastructure

## Requeriments

* Azure subscription
* Log Analytics account deployed
* Entra ID group for AKS RBAC
* Azure Container registry

### Create an SSH key pair

1. Go to https://shell.azure.com to open Cloud Shell in your browser.
2. Create an SSH key pair using the az sshkey create Azure CLI command or the ssh-keygen command.

```bash
#Create a resource group
az group create --name myAksResourceGroup --location eastus2

# Create an SSH key pair using Azure CLI
az sshkey create --name "mySSHKey" --resource-group "myAksResourceGroup"

# Create an SSH key pair using ssh-keygen
ssh-keygen -t rsa -b 4096

# Get the id of your Log Analytics
az monitor log-analytics workspace show \
  --resource-group myResourceGroup \
  --workspace-name myWorkspace \
  --query id \
  --output tsv

```

### Deploy AKS

1. save that ssh-key for the next steps

```bash
az deployment group create \
  --resource-group myAksResourceGroup \
  --template-file aks.bicep \
  --parameters \
    clusterName='aks101cluster' \
    location='eastus' \
    dnsPrefix='aks' \
    osDiskSizeGB=0 \
    agentCount=3 \
    agentVMSize='standard_d2s_v3' \
    linuxAdminUsername='azureuser' \
    sshRSAPublicKey='ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQC7...' \
    aadGroupObjectId='00000000-0000-0000-0000-000000000000' \
    vnetName='myVnet' \
    vnetAddressPrefix='10.10.0.0/16' \
    subnetName='mySubnet' \
    subnetAddressPrefix='10.10.1.0/24' \
    logAnalyticsWorkspaceId='/subscriptions/00000000-0000-0000-0000-000000000000/resourceGroups/myAksResourceGroup/providers/Microsoft.OperationalInsights/workspaces/myWorkspace' \
    uamiName='myUami'

```
