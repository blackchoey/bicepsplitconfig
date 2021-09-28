param sku string
param serverFarmsName string
param webAppName string
param simpelAuthPackageUri string

resource serverFarms 'Microsoft.Web/serverfarms@2020-06-01' = {
  name: serverFarmsName
  location: resourceGroup().location
  sku: {
    name: sku
  }
  kind: 'app'
}

resource webApp 'Microsoft.Web/sites@2020-06-01' = {
  kind: 'app'
  name: webAppName
  location: resourceGroup().location
  properties: {
    serverFarmId: serverFarms.id
  }
}

resource simpleAuthDeploy 'Microsoft.Web/sites/extensions@2021-01-15' = {
  parent: webApp
  name: 'MSDeploy'
  properties: {
    packageUri: simpelAuthPackageUri
  }
}

output webAppResourceId string = webApp.id
output endpoint string = 'https://${webApp.properties.defaultHostName}'
