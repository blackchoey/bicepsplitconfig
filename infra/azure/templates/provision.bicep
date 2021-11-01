@secure()
param provisionParameters object

// Resources for frontend hosting
module frontendHostingProvision './provision/frontendHosting.bicep' = {
  name: 'frontendHostingProvision'
  params: {
    provisionParameters: provisionParameters
  }
}

output frontendHostingOutput object = {
  teamsFxPluginId: 'fx-resource-frontend'
  domain: frontendHostingProvision.outputs.domain
  endpoint: frontendHostingProvision.outputs.endpoint
  resourceId: frontendHostingProvision.outputs.resourceId
}

// Resources for identity
module userAssignedIdentityProvision './provision/userAssignedIdentity.bicep' = {
  name: 'userAssignedIdentityProvision'
  params: {
    provisionParameters: provisionParameters
  }
}

output identityOutput object = {
  teamsFxPluginId: 'fx-resource-identity'
  resourceId: userAssignedIdentityProvision.outputs.resourceId
  clientId: userAssignedIdentityProvision.outputs.clientId
}

// Resources for Azure SQL
module sqlProvision './provision/sql.bicep' = {
  name: 'sqlProvision'
  params: {
    provisionParameters: provisionParameters
  }
}

output sqlOutput object = {
  teamsFxPluginId: 'fx-resource-azure-sql'
  sqlServerResourceId: sqlProvision.outputs.sqlServerResourceId
  sqlDatabaseName: sqlProvision.outputs.sqlDatabaseName
  sqlServerEndpoint: sqlProvision.outputs.sqlServerEndpoint
}

// Resources for bot
module botProvision './provision/bot.bicep' = {
  name: 'botProvision'
  params: {
    provisionParameters: provisionParameters
    userAssignedIdentityId: userAssignedIdentityProvision.outputs.resourceId
  }
}

output botHostingOutput object = {
  teamsFxPluginId: 'fx-resource-bot'
  webAppEndpoint: botProvision.outputs.webAppEndpoint
  webAppResourceId: botProvision.outputs.webAppResourceId
  webAppHostName: botProvision.outputs.webAppHostName
}

// Resources for Azure Functions
module functionProvision './provision/function.bicep' = {
  name: 'functionProvision'
  params: {
    provisionParameters: provisionParameters
    userAssignedIdentityId: userAssignedIdentityProvision.outputs.resourceId
  }
}

output functionOutput object = {
  teamsFxPluginId: 'fx-resource-function'
  functionAppResourceId: functionProvision.outputs.functionAppResourceId
  endpoint: functionProvision.outputs.functionAppEndpoint
}

// Resources for Simple Auth
module simpleAuthProvision './provision/simpleAuth.bicep' = {
  name: 'simpleAuthProvision'
  params: {
    provisionParameters: provisionParameters
    userAssignedIdentityId: userAssignedIdentityProvision.outputs.resourceId
  }
}

output simpleAuthOutput object = {
  teamsFxPluginId: 'fx-resource-simple-auth'
  endpoint: simpleAuthProvision.outputs.endpoint
  webAppResourceId: simpleAuthProvision.outputs.webAppResourceId
}

// Resources for APIM
module apimProvision './provision/apim.bicep' = {
  name: 'apimProvision'
  params: {
    provisionParameters: provisionParameters
  }
}

output apimOutput object = {
  teamsFxPluginId: 'fx-resource-apim'
  serviceResourceId: apimProvision.outputs.serviceResourceId
  productResourceId: apimProvision.outputs.productResourceId
}
