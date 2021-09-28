@secure()
param provisionParameters object

var resourceBaseName = provisionParameters.resourceBaseName

// Resources for frontend hosting
var frontendHostingStorageName = contains(provisionParameters, 'frontendHostingStorageName') ? provisionParameters['frontendHostingStorageName'] : 'frontendstg${uniqueString(resourceBaseName)}'

module frontendHostingProvision './provision/frontendHostingProvision.bicep' = {
  name: 'frontendHostingProvision'
  params: {
    storageName: frontendHostingStorageName
  }
}

output frontendHostingOutput object = {
  teamsFxPluginId: 'fx-resource-frontend'
  domain: frontendHostingProvision.outputs.domain
  endpoint: frontendHostingProvision.outputs.endpoint
  resourceId: frontendHostingProvision.outputs.resourceId
}

// Resources for identity
var userAssignedIdentityName = contains(provisionParameters, 'userAssignedIdentityName') ? provisionParameters['userAssignedIdentityName'] : '${resourceBaseName}-managedIdentity'

module userAssignedIdentityProvision './provision/userAssignedIdentityProvision.bicep' = {
  name: 'userAssignedIdentityProvision'
  params: {
    identityName: userAssignedIdentityName
  }
}

output identityOutput object = {
  teamsFxPluginId: 'fx-resource-identity'
  resourceId: userAssignedIdentityProvision.outputs.resourceId
  clientId: userAssignedIdentityProvision.outputs.clientId
}

// Resources for Azure SQL
var azureSqlAdmin = provisionParameters['azureSqlAdmin']
var azureSqlAdminPassword = provisionParameters['azureSqlAdminPassword']
var azureSqlServerName = contains(provisionParameters, 'azureSqlServerName') ? provisionParameters['azureSqlServerName'] : '${resourceBaseName}-sql-server'
var azureSqlDatabaseName = contains(provisionParameters, 'azureSqlDatabaseName') ? provisionParameters['azureSqlDatabaseName'] : '${resourceBaseName}-database'

module azureSqlProvision './provision/azureSqlProvision.bicep' = {
  name: 'azureSqlProvision'
  params: {
    sqlServerName: azureSqlServerName
    sqlDatabaseName: azureSqlDatabaseName
    administratorLogin: azureSqlAdmin
    administratorLoginPassword: azureSqlAdminPassword
  }
}

output azureSqlOutput object = {
  teamsFxPluginId: 'fx-resource-azure-sql'
  sqlServerResourceId: azureSqlProvision.outputs.sqlServerResourceId
  sqlDatabaseName: azureSqlProvision.outputs.sqlDatabaseName
  sqlServerEndpoint: azureSqlProvision.outputs.sqlServerEndpoint
}

// Resources for bot
var botAadAppClientId = provisionParameters['botAadAppClientId']
var botAadAppClientSecret = provisionParameters['botAadAppClientSecret']
var botServiceName = contains(provisionParameters, 'botServiceName') ? provisionParameters['botServiceName'] : '${resourceBaseName}-bot-service'
var botDisplayName = contains(provisionParameters, 'botDisplayName') ? provisionParameters['botDisplayName'] : '${resourceBaseName}-bot-displayname'
var botServerfarmsName = contains(provisionParameters, 'botServerfarmsName') ? provisionParameters['botServerfarmsName'] : '${resourceBaseName}-bot-serverfarms'
var botWebAppSKU = contains(provisionParameters, 'botWebAppSKU') ? provisionParameters['botWebAppSKU'] : 'F1'
var botSitesName = contains(provisionParameters, 'botSitesName') ? provisionParameters['botSitesName'] : '${resourceBaseName}-bot-sites'

module botProvision './provision/botProvision.bicep' = {
  name: 'botProvision'
  params: {
    serverfarmsName: botServerfarmsName
    botServiceName: botServiceName
    botAadAppClientId: botAadAppClientId
    botAadAppClientSecret: botAadAppClientSecret
    botDisplayName: botDisplayName
    webAppName: botSitesName
    webAppSKU: botWebAppSKU
    userAssignedIdentityId: userAssignedIdentityProvision.outputs.resourceId
  }
}

output botOutput object = {
  teamsFxPluginId: 'fx-resource-bot'
  webAppEndpoint: botProvision.outputs.webAppEndpoint
  webAppResourceId: botProvision.outputs.webAppResourceId
  webAppHostName: botProvision.outputs.webAppHostName
}

// Resources for Azure Functions
var functionServerfarmsName = contains(provisionParameters, 'functionServerfarmsName') ? provisionParameters['functionServerfarmsName'] : '${resourceBaseName}-function-serverfarms'
var functionWebappName = contains(provisionParameters, 'functionWebappName') ? provisionParameters['functionWebappName'] : '${resourceBaseName}-function-webapp'
var functionStorageName = contains(provisionParameters, 'functionStorageName') ? provisionParameters['functionStorageName'] : 'functionstg${uniqueString(resourceBaseName)}'

module functionProvision './provision/functionProvision.bicep' = {
  name: 'functionProvision'
  params: {
    functionAppName: functionWebappName
    serverfarmsName: functionServerfarmsName
    storageName: functionStorageName
    userAssignedIdentityId: userAssignedIdentityProvision.outputs.resourceId
  }
}

output functionOutput object = {
  teamsFxPluginId: 'fx-resource-function'
  functionAppResourceId: functionProvision.outputs.functionAppResourceId
  endpoint: functionProvision.outputs.functionAppEndpoint
}

// Resources for Simple Auth
var simpleAuthSku = contains(provisionParameters, 'simpleAuthSku') ? provisionParameters['simpleAuthSku'] : 'F1'
var simpleAuthServerFarmsName = contains(provisionParameters, 'simpleAuthServerFarmsName') ? provisionParameters['simpleAuthServerFarmsName'] : '${resourceBaseName}-simpleAuth-serverfarms'
var simpleAuthWebAppName = contains(provisionParameters, 'simpleAuthWebAppName') ? provisionParameters['simpleAuthWebAppName'] : '${resourceBaseName}-simpleAuth-webapp'
var simpleAuthPackageUri = contains(provisionParameters, 'simpleAuthPackageUri') ? provisionParameters['simpleAuthPackageUri'] : 'https://github.com/OfficeDev/TeamsFx/releases/download/simpleauth@0.1.0/Microsoft.TeamsFx.SimpleAuth_0.1.0.zip'

module simpleAuthProvision './provision/simpleAuthProvision.bicep' = {
  name: 'simpleAuthProvision'
  params: {
    serverFarmsName: simpleAuthServerFarmsName
    webAppName: simpleAuthWebAppName
    sku: simpleAuthSku
    simpelAuthPackageUri: simpleAuthPackageUri
  }
}

output simpleAuthOutput object = {
  teamsFxPluginId: 'fx-resource-simple-auth'
  endpoint: simpleAuthProvision.outputs.endpoint
  webAppResourceId: simpleAuthProvision.outputs.webAppResourceId
}
