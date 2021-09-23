@secure()
param provisionParameters object

var resourceBaseName = provisionParameters.resourceBaseName

// fx-aad
var m365ClientId = provisionParameters['m365ClientId']
var m365ClientSecret = provisionParameters['m365ClientSecret']
var m365TenantId = provisionParameters['m365TenantId']
var m365OauthAuthorityHost = provisionParameters['m365OauthAuthorityHost']

var m365ApplicationIdUri = 'api://${frontendHostingProvision.outputs.domain}/botid-${bot_aadClientId}' // need to be removed

// fx-frontend-hosting
var frontendHosting_storageName = contains(provisionParameters, 'frontendHosting_storageName') ? provisionParameters['frontendHosting_storageName'] : 'frontendstg${uniqueString(resourceBaseName)}'

module frontendHostingProvision './frontendHostingProvision.bicep' = {
  name: 'frontendHostingProvision'
  params: {
    frontendHostingStorageName: frontendHosting_storageName
  }
}

output teamsFxFeHostingOutput object = {
  teamsFxProfile: {
    'fx-frontend-hosting': {
      domain: frontendHostingProvision.outputs.domain
      endpoint: frontendHostingProvision.outputs.endpoint
      resourceId: frontendHostingProvision.outputs.resourceId
    }
  }
}

// fx-identity
var identity_managedIdentityName = contains(provisionParameters, 'identity_managedIdentityName') ? provisionParameters['identity_managedIdentityName'] : '${resourceBaseName}-managedIdentity'

module userAssignedIdentityProvision './userAssignedIdentityProvision.bicep' = {
  name: 'userAssignedIdentityProvision'
  params: {
    managedIdentityName: identity_managedIdentityName
  }
}

output teamsFxIdentityOutput object = {
  teamsFxProfile: {
    'fx-identity': {
      resourceId: userAssignedIdentityProvision.outputs.identityId
    }
  }
}

// fx-sql
var azureSql_admin = provisionParameters['azureSql_admin']
var azureSql_adminPassword = provisionParameters['azureSql_adminPassword']
var azureSql_serverName = contains(provisionParameters, 'azureSql_serverName') ? provisionParameters['azureSql_serverName'] : '${resourceBaseName}-sql-server'
var azureSql_databaseName = contains(provisionParameters, 'azureSql_databaseName') ? provisionParameters['azureSql_databaseName'] : '${resourceBaseName}-database'

module azureSqlProvision './azureSqlProvision.bicep' = {
  name: 'azureSqlProvision'
  params: {
    sqlServerName: azureSql_serverName
    sqlDatabaseName: azureSql_databaseName
    administratorLogin: azureSql_admin
    administratorLoginPassword: azureSql_adminPassword
  }
}

output teamsFxSqlOutput object = {
  teamsFxProfile: {
    'fx-sql': {
      sqlServerResourceId: azureSqlProvision.outputs.sqlServerResourceId
    }
  }
}

// fx-bot
var bot_aadClientId = provisionParameters['bot_aadClientId']
var bot_aadClientSecret = provisionParameters['bot_aadClientSecret']
var bot_serviceName = contains(provisionParameters, 'bot_serviceName') ? provisionParameters['bot_serviceName'] : '${resourceBaseName}-bot-service'
var bot_displayName = contains(provisionParameters, 'bot_displayName') ? provisionParameters['bot_displayName'] : '${resourceBaseName}-bot-displayname'
var bot_serverfarmsName = contains(provisionParameters, 'bot_serverfarmsName') ? provisionParameters['bot_serverfarmsName'] : '${resourceBaseName}-bot-serverfarms'
var bot_webAppSKU = contains(provisionParameters, 'bot_webAppSKU') ? provisionParameters['bot_webAppSKU'] : 'F1'
var bot_serviceSKU = contains(provisionParameters, 'bot_serviceSKU') ? provisionParameters['bot_serviceSKU'] : 'F1'
var bot_sitesName = contains(provisionParameters, 'bot_sitesName') ? provisionParameters['bot_sitesName'] : '${resourceBaseName}-bot-sites'
var authLoginUriSuffix = contains(provisionParameters, 'authLoginUriSuffix') ? provisionParameters['authLoginUriSuffix'] : 'auth-start.html'

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

output teamsFxBotOutput object = {
  teamsFxProfile: {
    'fx-bot': {
      webAppResourceId: botProvision.outputs.webAppResourceId
    }
  }
}

// fx-function
var function_serverfarmsName = contains(provisionParameters, 'function_serverfarmsName') ? provisionParameters['function_serverfarmsName'] : '${resourceBaseName}-function-serverfarms'
var function_webappName = contains(provisionParameters, 'function_webappName') ? provisionParameters['function_webappName'] : '${resourceBaseName}-function-webapp'
var function_storageName = contains(provisionParameters, 'function_storageName') ? provisionParameters['function_storageName'] : 'functionstg${uniqueString(resourceBaseName)}'

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

output teamsFxFunctionOutput object = {
  teamsFxProfile: {
    'fx-function': {
      functionAppResourceId: functionProvision.outputs.functionAppResourceId
    }
  }
}

// fx-simpleauth
var simpleAuth_sku = contains(provisionParameters, 'simpleAuth_sku') ? provisionParameters['simpleAuth_sku'] : 'F1'
var simpleAuth_serverFarmsName = contains(provisionParameters, 'simpleAuth_serverFarmsName') ? provisionParameters['simpleAuth_serverFarmsName'] : '${resourceBaseName}-simpleAuth-serverfarms'
var simpleAuth_webAppName = contains(provisionParameters, 'simpleAuth_webAppName') ? provisionParameters['simpleAuth_webAppName'] : '${resourceBaseName}-simpleAuth-webapp'
var simpleAuth_packageUri = contains(provisionParameters, 'simpleAuth_packageUri') ? provisionParameters['simpleAuth_packageUri'] : 'https://github.com/OfficeDev/TeamsFx/releases/download/simpleauth@0.1.0/Microsoft.TeamsFx.SimpleAuth_0.1.0.zip'

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
