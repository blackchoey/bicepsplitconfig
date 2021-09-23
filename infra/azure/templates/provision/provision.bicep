@secure()
param teamsFxProvisionParameters object

var resourceBaseName = teamsFxProvisionParameters.resourceBaseName

// fx-aad
var m365ClientId = teamsFxProvisionParameters['m365ClientId']
var m365ClientSecret = teamsFxProvisionParameters['m365ClientSecret']
var m365TenantId = teamsFxProvisionParameters['m365TenantId']
var m365OauthAuthorityHost = teamsFxProvisionParameters['m365OauthAuthorityHost']

var m365ApplicationIdUri = 'api://${frontendHostingProvision.outputs.domain}/botid-${bot_aadClientId}'  // need to be removed

// fx-frontend-hosting
var frontendHosting_storageName = contains(teamsFxProvisionParameters, 'frontendHosting_storageName') ? teamsFxProvisionParameters['frontendHosting_storageName'] : 'frontendstg${uniqueString(resourceBaseName)}'

module frontendHostingProvision './frontendHostingProvision.bicep' = {
  name: 'frontendHostingProvision'
  params: {
    frontendHostingStorageName: frontendHosting_storageName
  }
}

// fx-identity
var identity_managedIdentityName = contains(teamsFxProvisionParameters, 'identity_managedIdentityName') ? teamsFxProvisionParameters['identity_managedIdentityName'] : '${resourceBaseName}-managedIdentity'

module userAssignedIdentityProvision './userAssignedIdentityProvision.bicep' = {
  name: 'userAssignedIdentityProvision'
  params: {
    managedIdentityName: identity_managedIdentityName
  }
}

// fx-sql
var azureSql_admin = teamsFxProvisionParameters['azureSql_admin']
var azureSql_adminPassword = teamsFxProvisionParameters['azureSql_adminPassword']
var azureSql_serverName = contains(teamsFxProvisionParameters, 'azureSql_serverName') ? teamsFxProvisionParameters['azureSql_serverName'] : '${resourceBaseName}-sql-server'
var azureSql_databaseName = contains(teamsFxProvisionParameters, 'azureSql_databaseName') ? teamsFxProvisionParameters['azureSql_databaseName'] : '${resourceBaseName}-database'

module azureSqlProvision './azureSqlProvision.bicep' = {
  name: 'azureSqlProvision'
  params: {
    sqlServerName: azureSql_serverName
    sqlDatabaseName: azureSql_databaseName
    administratorLogin: azureSql_admin
    administratorLoginPassword: azureSql_adminPassword
  }
}

// fx-bot
var bot_aadClientId = teamsFxProvisionParameters['bot_aadClientId']
var bot_aadClientSecret = teamsFxProvisionParameters['bot_aadClientSecret']
var bot_serviceName = contains(teamsFxProvisionParameters, 'bot_serviceName') ? teamsFxProvisionParameters['bot_serviceName'] : '${resourceBaseName}-bot-service'
var bot_displayName = contains(teamsFxProvisionParameters, 'bot_displayName') ? teamsFxProvisionParameters['bot_displayName'] : '${resourceBaseName}-bot-displayname'
var bot_serverfarmsName = contains(teamsFxProvisionParameters, 'bot_serverfarmsName') ? teamsFxProvisionParameters['bot_serverfarmsName'] : '${resourceBaseName}-bot-serverfarms'
var bot_webAppSKU = contains(teamsFxProvisionParameters, 'bot_webAppSKU') ? teamsFxProvisionParameters['bot_webAppSKU'] : 'F1'
var bot_serviceSKU = contains(teamsFxProvisionParameters, 'bot_serviceSKU') ? teamsFxProvisionParameters['bot_serviceSKU'] : 'F1'
var bot_sitesName = contains(teamsFxProvisionParameters, 'bot_sitesName') ? teamsFxProvisionParameters['bot_sitesName'] : '${resourceBaseName}-bot-sites'
var authLoginUriSuffix = contains(teamsFxProvisionParameters, 'authLoginUriSuffix') ? teamsFxProvisionParameters['authLoginUriSuffix'] : 'auth-start.html'

module botProvision './botProvision.bicep' = {
  name: 'botProvision'
  params: {
    botServerfarmsName: bot_serverfarmsName
    botServiceName: bot_serviceName
    botAadClientId: bot_aadClientId
    botDisplayName: bot_displayName
    botServiceSKU: bot_serviceSKU
    botWebAppName: bot_sitesName
    botWebAppSKU: bot_webAppSKU
    identityName: userAssignedIdentityProvision.outputs.identityName
  }
}
module botConfiguration './botConfiguration.bicep' = {
  name: 'botConfiguration'
  dependsOn: [
    botProvision
  ]
  params: {
    botAadClientId: bot_aadClientId
    botAadClientSecret: bot_aadClientSecret
    botServiceName: bot_serviceName
    botWebAppName: bot_sitesName
    authLoginUriSuffix: authLoginUriSuffix
    botEndpoint: botProvision.outputs.botWebAppEndpoint
    m365ApplicationIdUri: m365ApplicationIdUri
    m365ClientId: m365ClientId
    m365ClientSecret: m365ClientSecret
    m365TenantId: m365TenantId
    m365OauthAuthorityHost: m365OauthAuthorityHost
  }
}

output fxBotPluginOutput object = {
  profile: {
    resourceId: botProvision.outputs.botWebAppName // to be update
  }
}

// fx-function
var function_serverfarmsName = contains(teamsFxProvisionParameters, 'function_serverfarmsName') ? teamsFxProvisionParameters['function_serverfarmsName'] : '${resourceBaseName}-function-serverfarms'
var function_webappName = contains(teamsFxProvisionParameters, 'function_webappName') ? teamsFxProvisionParameters['function_webappName'] : '${resourceBaseName}-function-webapp'
var function_storageName = contains(teamsFxProvisionParameters, 'function_storageName') ? teamsFxProvisionParameters['function_storageName'] : 'functionstg${uniqueString(resourceBaseName)}'

module functionProvision './functionProvision.bicep' = {
  name: 'functionProvision'
  params: {
    functionAppName: function_webappName
    functionServerfarmsName: function_serverfarmsName
    functionStorageName: function_storageName
    identityName: userAssignedIdentityProvision.outputs.identityName
  }
}
module functionConfiguration './functionConfiguration.bicep' = {
  name: 'functionConfiguration'
  dependsOn: [
    functionProvision
  ]
  params: {
    functionAppName: function_webappName
    functionStorageName: function_storageName
    m365ClientId: m365ClientId
    m365ClientSecret: m365ClientSecret
    m365TenantId: m365TenantId
    m365ApplicationIdUri: m365ApplicationIdUri
    m365OauthAuthorityHost: m365OauthAuthorityHost
  }
}

// fx-simpleauth
var simpleAuth_sku = contains(teamsFxProvisionParameters, 'simpleAuth_sku') ? teamsFxProvisionParameters['simpleAuth_sku'] : 'F1'
var simpleAuth_serverFarmsName = contains(teamsFxProvisionParameters, 'simpleAuth_serverFarmsName') ? teamsFxProvisionParameters['simpleAuth_serverFarmsName'] : '${resourceBaseName}-simpleAuth-serverfarms'
var simpleAuth_webAppName = contains(teamsFxProvisionParameters, 'simpleAuth_webAppName') ? teamsFxProvisionParameters['simpleAuth_webAppName'] : '${resourceBaseName}-simpleAuth-webapp'
var simpleAuth_packageUri = contains(teamsFxProvisionParameters, 'simpleAuth_packageUri') ? teamsFxProvisionParameters['simpleAuth_packageUri'] : 'https://github.com/OfficeDev/TeamsFx/releases/download/simpleauth@0.1.0/Microsoft.TeamsFx.SimpleAuth_0.1.0.zip'

module simpleAuthProvision './simpleAuthProvision.bicep' = {
  name: 'simpleAuthProvision'
  params: {
    simpleAuthServerFarmsName: simpleAuth_serverFarmsName
    simpleAuthWebAppName: simpleAuth_webAppName
    sku: simpleAuth_sku
  }
}
module simpleAuthConfiguration './simpleAuthConfiguration.bicep' = {
  name: 'simpleAuthConfiguration'
  dependsOn: [
    simpleAuthProvision
  ]
  params: {
    simpleAuthWebAppName: simpleAuth_webAppName
    m365ClientId: m365ClientId
    m365ClientSecret: m365ClientSecret
    m365ApplicationIdUri: m365ApplicationIdUri
    frontendHostingStorageEndpoint: frontendHostingProvision.outputs.endpoint
    m365TenantId: m365TenantId
    oauthAuthorityHost: m365OauthAuthorityHost
    simpelAuthPackageUri: simpleAuth_packageUri
  }
}



output frontendHosting_storageResourceId string = frontendHostingProvision.outputs.resourceId
output frontendHosting_endpoint string = frontendHostingProvision.outputs.endpoint
output frontendHosting_domain string = frontendHostingProvision.outputs.domain
output identity_identityName string = userAssignedIdentityProvision.outputs.identityName
output identity_identityId string = userAssignedIdentityProvision.outputs.identityId
output identity_identity string = userAssignedIdentityProvision.outputs.identity
output azureSql_sqlEndpoint string = azureSqlProvision.outputs.sqlEndpoint
output azureSql_databaseName string = azureSqlProvision.outputs.databaseName
output bot_webAppSKU string = botProvision.outputs.botWebAppSKU
output bot_serviceSKU string = botProvision.outputs.botServiceSKU
output bot_webAppName string = botProvision.outputs.botWebAppName
output bot_domain string = botProvision.outputs.botDomain
output bot_appServicePlanName string = botProvision.outputs.appServicePlanName
output bot_serviceName string = botProvision.outputs.botServiceName
output bot_webAppEndpoint string = botProvision.outputs.botWebAppEndpoint
output function_functionEndpoint string = functionProvision.outputs.functionEndpoint
output function_appResourceId string = functionProvision.outputs.functionAppResourceId
output simpleAuth_skuName string = simpleAuthProvision.outputs.skuName
output simpleAuth_endpoint string = simpleAuthProvision.outputs.endpoint
output simpleAuth_webAppName string = simpleAuthProvision.outputs.webAppName
output simpleAuth_appServicePlanName string = simpleAuthProvision.outputs.appServicePlanName
