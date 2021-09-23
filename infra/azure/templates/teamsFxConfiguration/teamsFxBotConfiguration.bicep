@secure()
param provisionParameters object
param provisionOutputs object

var botWebAppName = split(provisionOutputs.teamsFxBotOutput.profile.resourceId, '/')[8]
var functionEndpoint = provisionOutputs.teamsFxFunctionOutput.profile.endpoint
var sqlDatabaseName = provisionOutputs.teamsFxSqlOutput.sqlDatabaseName
var sqlEndpoint = provisionOutputs.teamsFxSqlOutput.sqlEndpoint
var identityId = provisionOutputs.teamsFxIdentityOutput.profile.identityId
var m365ApplicationIdUri = 'api://${provisionOutputs.teamsFxFeHostingOutput.domain}/botid-${provisionParameters.bot_aadClientId}'

var currentAppSettings = list('${provisionOutputs.teamsFxBotOutput.profile.resourceId}/config/appsettings', '2020-12-01').properties

resource botWebAppSettings 'Microsoft.Web/sites/config@2021-01-01' = {
    name: '${botWebAppName}/appsettings'
    properties: union(currentAppSettings, {
        API_ENDPOINT: functionEndpoint
        SQL_DATABASE_NAME: sqlDatabaseName
        SQL_ENDPOINT: sqlEndpoint
        IDENTITY_ID: identityId
        M365_APPLICATION_ID_URI: m365ApplicationIdUri // this value needs to be updated when user adds new capability
    })
}
