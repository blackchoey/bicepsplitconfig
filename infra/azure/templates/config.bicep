@secure()
param provisionParameters object
param provisionOutputs object

var simpleAuthCurrentAppSettings = list('${provisionOutputs.simpleAuthOutput.value.webAppResourceId}/config/appsettings', '2021-01-15').properties

module teamsFxSimpleAuthConfig './teamsFxConfiguration/teamsFxSimpleAuthConfiguration.bicep' = {
  name: 'addTeamsFxSimpleAuthConfiguration'
  params: {
    provisionParameters: provisionParameters
    provisionOutputs: provisionOutputs
    currentAppSettings: simpleAuthCurrentAppSettings
  }
}

var botCurrentAppSettings = list('${provisionOutputs.botOutput.value.webAppResourceId}/config/appsettings', '2021-01-15').properties

module teamsFxBotConfig './teamsFxConfiguration/teamsFxBotConfiguration.bicep' = {
  name: 'addTeamsFxBotConfiguration'
  params: {
    provisionParameters: provisionParameters
    provisionOutputs: provisionOutputs
    currentAppSettings: botCurrentAppSettings
  }
}

var functionCurrentConfigs = reference('${provisionOutputs.functionOutput.value.functionAppResourceId}/config/web', '2021-01-15')
var functionCurrentAppSettings = list('${provisionOutputs.functionOutput.value.functionAppResourceId}/config/appsettings', '2021-01-15').properties

module teamsFxFunctionConfig './teamsFxConfiguration/teamsFxFunctionConfiguration.bicep' = {
  name: 'addTeamsFxFunctionConfiguration'
  params: {
    provisionParameters: provisionParameters
    provisionOutputs: provisionOutputs
    currentConfigs: functionCurrentConfigs
    currentAppSettings: functionCurrentAppSettings
  }
}
