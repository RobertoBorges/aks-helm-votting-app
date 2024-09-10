@description('The name of the Virtual Network.')
param vnetName string

@description('The address space of the Virtual Network.')
param vnetAddressPrefix string = '10.10.0.0/16'

@description('The name of the Subnet.')
param subnetName string

@description('The address prefix of the Subnet.')
param subnetAddressPrefix string = '10.10.1.0/24'

@description('The location of the Virtual Network.')
param location string = resourceGroup().location

resource vnet 'Microsoft.Network/virtualNetworks@2022-05-01' = {
  name: vnetName
  location: location
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetAddressPrefix
      ]
    }
    subnets: [
      {
        name: subnetName
        properties: {
          addressPrefix: subnetAddressPrefix
        }
      }
    ]
  }
}

output vnetId string = vnet.id
output subnetId string = vnet.properties.subnets[0].id
