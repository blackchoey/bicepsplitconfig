param teamsFxProvisionParameters object
param provisionOutputs object

var m365ClientId = teamsFxProvisionParameters.m365ClientId
var m365TenantId = teamsFxProvisionParameters.m365TenantId
var m365OauthAuthorityHost = teamsFxProvisionParameters.m365OauthAuthorityHost

var functionAppName = split(provisionOutputs.fxFunctionPluginOutput.profile.resourceId, '/')[8]
var tabAppEndpoint = provisionOutputs.fxFeHostingPlugin.profile.endpoint
var sqlDatabaseName = provisionOutputs.fxSqlPluginOutput.sqlDatabaseName
var sqlEndpoint = provisionOutputs.fxSqlPluginOutput.sqlEndpoint
var identityId = provisionOutputs.fxIdentityPluginOutput.profile.identityId
var m365ApplicationIdUri = 'api://${provisionOutputs.fxFeHostingPluginOutput.domain}/botid-${teamsFxProvisionParameters.bot_aadClientId}'

var oauthAuthority = uri(m365OauthAuthorityHost, m365TenantId)

var currentCors = list('${provisionOutputs.fxFunctionPluginOutput.profile.resourceId}', '2020-12-01').properties.cors.allowedOrigins

resource functionAppConfig 'Microsoft.Web/sites/config@2021-01-15' = {
  name: '${functionAppName}/web'
  kind: 'functionapp'
  properties: {
    cors: {
      allowedOrigins: union(currentCors, [
        tabAppEndpoint
      ])
    }
  }
}

var currentAppSettings = list('${provisionOutputs.fxFunctionPluginOutput.profile.resourceId}/config/appsettings', '2020-12-01').properties

resource functionAppAppSettings 'Microsoft.Web/sites/config@2021-01-15' = {
  name: '${functionAppName}/appsettings'
  properties: union(currentAppSettings, {
    IDENTITY_ID: identityId
    SQL_DATABASE_NAME: sqlDatabaseName
    SQL_ENDPOINT: sqlEndpoint
  })
}

var currentAllowedAudiences= list('${provisionOutputs.fxFunctionPluginOutput.profile.resourceId}/config/authsettings', '2020-12-01').properties.allowedAudiences

resource functionAppAuthSettings 'Microsoft.Web/sites/config@2021-01-15' = {
  name: '${functionAppName}/authsettings'
  properties: {
    // enabled: true
    // defaultProvider: 'AzureActiveDirectory'
    // clientId: m365ClientId
    // issuer: '${oauthAuthority}/v2.0'
    allowedAudiences: union(currentAllowedAudiences, [
      m365ApplicationIdUri  // there may be a problem that old items are not removed
    ])
  }
}
