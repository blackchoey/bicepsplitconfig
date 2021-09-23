@secure()
param provisionParameters object
param provisionOutputs object

var functionAppName = split(provisionOutputs.teamsFxFunctionOutput.profile.resourceId, '/')[8]
var tabAppEndpoint = provisionOutputs.teamsFxFeHostingOutput.profile.endpoint
var sqlDatabaseName = provisionOutputs.teamsFxSqlOutput.sqlDatabaseName
var sqlEndpoint = provisionOutputs.teamsFxSqlOutput.sqlEndpoint
var identityId = provisionOutputs.teamsFxIdentityOutput.profile.identityId
var m365ApplicationIdUri = 'api://${provisionOutputs.teamsFxFeHostingOutput.domain}/botid-${provisionParameters.bot_aadClientId}'

var currentCors = list('${provisionOutputs.teamsFxFunctionOutput.profile.resourceId}', '2020-12-01').properties.cors.allowedOrigins

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

var currentAppSettings = list('${provisionOutputs.teamsFxFunctionOutput.profile.resourceId}/config/appsettings', '2020-12-01').properties

resource functionAppAppSettings 'Microsoft.Web/sites/config@2021-01-15' = {
  name: '${functionAppName}/appsettings'
  properties: union(currentAppSettings, {
    IDENTITY_ID: identityId
    SQL_DATABASE_NAME: sqlDatabaseName
    SQL_ENDPOINT: sqlEndpoint
  })
}

var currentAllowedAudiences= list('${provisionOutputs.teamsFxFunctionOutput.profile.resourceId}/config/authsettings', '2020-12-01').properties.allowedAudiences

resource functionAppAuthSettings 'Microsoft.Web/sites/config@2021-01-15' = {
  name: '${functionAppName}/authsettings'
  properties: {
    allowedAudiences: union(currentAllowedAudiences, [
      m365ApplicationIdUri
    ])
  }
}
