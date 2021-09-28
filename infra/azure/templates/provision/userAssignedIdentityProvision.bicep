param identityName string

resource managedIdentity 'Microsoft.ManagedIdentity/userAssignedIdentities@2018-11-30' = {
  name: identityName
  location: resourceGroup().location
}

output resourceId string = managedIdentity.id
output clientId string = managedIdentity.properties.clientId
