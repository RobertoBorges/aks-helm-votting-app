@description('The name of the User Assigned Managed Identity.')
param uamiName string

@description('The location of the User Assigned Managed Identity.')
param location string = resourceGroup().location

resource uami 'Microsoft.ManagedIdentity/userAssignedIdentities@2023-01-31' = {
  name: uamiName
  location: location
}

output uamiId string = uami.id
output uamiClientId string = uami.id
