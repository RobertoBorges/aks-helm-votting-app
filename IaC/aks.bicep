@description('The name of the Managed Cluster resource.')
param clusterName string = 'aks101cluster'

@description('The location of the Managed Cluster resource.')
param location string = resourceGroup().location

@description('Optional DNS prefix to use with hosted Kubernetes API server FQDN.')
param dnsPrefix string = 'aks'

@description('Disk size (in GB) to provision for each of the agent pool nodes. This value ranges from 0 to 1023. Specifying 0 will apply the default disk size for that agentVMSize.')
@minValue(0)
@maxValue(1023)
param osDiskSizeGB int = 0

@description('The number of nodes for the cluster.')
@minValue(1)
@maxValue(50)
param agentCount int = 3

@description('The size of the Virtual Machine.')
param agentVMSize string = 'standard_d2s_v3'

@description('User name for the Linux Virtual Machines.')
param linuxAdminUsername string

@description('Configure all linux machines with the SSH RSA public key string. Your key should include three parts, for example \'ssh-rsa AAAAB...snip...UcyupgH azureuser@linuxvm\'')
param sshRSAPublicKey string

@description('The Entra ID group object ID that will have access to the cluster.')
param aadGroupObjectId string

@description('The name of the Virtual Network.')
param vnetName string = 'myVnet'

@description('The address space of the Virtual Network.')
param vnetAddressPrefix string = '10.0.0.0/16'

@description('The name of the Subnet.')
param subnetName string = 'mySubnet'

@description('The address prefix of the Subnet.')
param subnetAddressPrefix string = '10.0.0.0/24'

@description('The Log Analytics workspace resource ID.')
param logAnalyticsWorkspaceId string

@description('The name of the User Assigned Managed Identity.')
param uamiName string = 'myUami'

module network 'vnet.bicep' = {
  name: 'networkDeployment'
  params: {
    vnetName: vnetName
    vnetAddressPrefix: vnetAddressPrefix
    subnetName: subnetName
    subnetAddressPrefix: subnetAddressPrefix
    location: location
  }
}

module uami 'uami.bicep' = {
  name: 'uamiDeployment'
  params: {
    uamiName: uamiName
    location: location
  }
}

resource aks 'Microsoft.ContainerService/managedClusters@2024-04-02-preview' = {
  name: clusterName
  location: location
  identity: {
    type: 'UserAssigned'
    userAssignedIdentities: {
      '${resourceId('Microsoft.ManagedIdentity/userAssignedIdentities', uamiName)}': {}
    }
  }
  properties: {
    dnsPrefix: dnsPrefix
    agentPoolProfiles: [
      {
        name: 'agentpool'
        osDiskSizeGB: osDiskSizeGB
        count: agentCount
        vmSize: agentVMSize
        osType: 'Linux'
        mode: 'System'
        vnetSubnetID: network.outputs.subnetId
      }
    ]
    linuxProfile: {
      adminUsername: linuxAdminUsername
      ssh: {
        publicKeys: [
          {
            keyData: sshRSAPublicKey
          }
        ]
      }
    }
    aadProfile: {
      managed: true
      adminGroupObjectIDs: [
        aadGroupObjectId
      ]
    }
    addonProfiles: {
      azureKeyvaultSecretsProvider: {
        enabled: true
        config: {
          enableSecretRotation: 'true'
          rotationPollInterval: '2m'
        }
      }
      omsagent: {
        enabled: true
        config: {
          logAnalyticsWorkspaceResourceID: logAnalyticsWorkspaceId
        }
      }
    }
    enableRBAC: true
    networkProfile: {
      networkPlugin: 'azure'
      networkPolicy: 'azure'
    }
    autoScalerProfile: {
      'scan-interval': '10s'
      'scale-down-delay-after-add': '15m'
      'scale-down-unneeded-time': '10m'
      'scale-down-unready-time': '20m'
    }
  }
  tags: {
    environment: 'production'
    owner: 'team-name'
  }
}

output controlPlaneFQDN string = aks.properties.fqdn
