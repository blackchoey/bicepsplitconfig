@secure()
param provisionParameters object
param provisionOutputs object

var simpleAuthCurrentAppSettings = list('${provisionOutputs.simpleAuthOutput.value.webAppResourceId}/config/appsettings', '2021-02-01').properties

module teamsFxSimpleAuthConfig './teamsFx/simpleAuth.bicep' = {
  name: 'addTeamsFxSimpleAuthConfiguration'
  params: {
    provisionParameters: provisionParameters
    provisionOutputs: provisionOutputs
    currentAppSettings: simpleAuthCurrentAppSettings
  }
}

var botCurrentAppSettings = list('${provisionOutputs.botHostingOutput.value.webAppResourceId}/config/appsettings', '2021-02-01').properties

module teamsFxBotConfig './teamsFx/bot.bicep' = {
  name: 'addTeamsFxBotConfiguration'
  params: {
    provisionParameters: provisionParameters
    provisionOutputs: provisionOutputs
    currentAppSettings: botCurrentAppSettings
  }
}

var functionCurrentConfigs = reference('${provisionOutputs.functionOutput.value.functionAppResourceId}/config/web', '2021-02-01')
var functionCurrentAppSettings = list('${provisionOutputs.functionOutput.value.functionAppResourceId}/config/appsettings', '2021-02-01').properties

module teamsFxFunctionConfig './teamsFx/function.bicep' = {
  name: 'addTeamsFxFunctionConfiguration'
  params: {
    provisionParameters: provisionParameters
    provisionOutputs: provisionOutputs
    currentConfigs: functionCurrentConfigs
    currentAppSettings: functionCurrentAppSettings
  }
}

module teamsFxApimConfig './teamsFx/apim.bicep' = {
  name: 'addTeamsFxApimConfiguration'
  params: {
    provisionParameters: provisionParameters
    provisionOutputs: provisionOutputs
  }
}

output apimConfigOutput object = {
  teamsFxPluginId: 'fx-resource-apim'
  authServiceResourceId: teamsFxApimConfig.outputs.authServiceResourceId
}
