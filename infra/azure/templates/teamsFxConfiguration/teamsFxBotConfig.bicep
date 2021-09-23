param teamsFxProvisionParameters object
param provisionOutputs object

var botWebAppName = split(provisionOutputs.fxBotPluginOutput.profile.resourceId, '/')[8]
var functionEndpoint = provisionOutputs.fxFunctionPluginOutput.profile.endpoint
var sqlDatabaseName = provisionOutputs.fxSqlPluginOutput.sqlDatabaseName
var sqlEndpoint = provisionOutputs.fxSqlPluginOutput.sqlEndpoint
var identityId = provisionOutputs.fxIdentityPluginOutput.profile.identityId
var m365ApplicationIdUri = 'api://${provisionOutputs.fxFeHostingPluginOutput.domain}/botid-${teamsFxProvisionParameters.bot_aadClientId}'

var currentAppSettings = list('${provisionOutputs.fxBotPluginOutput.profile.resourceId}/config/appsettings', '2020-12-01').properties

resource botWebAppSettings 'Microsoft.Web/sites/config@2021-01-01' = {
    name: '${botWebAppName}/appsettings'
    properties: union(currentAppSettings, {
        API_ENDPOINT: functionEndpoint
        SQL_DATABASE_NAME: sqlDatabaseName
        SQL_ENDPOINT: sqlEndpoint
        IDENTITY_ID: identityId
        M365_APPLICATION_ID_URI: m365ApplicationIdUri
    })
}
