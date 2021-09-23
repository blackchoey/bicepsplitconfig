param provisionParameters object
// param botSubscriptionId string
// param botResourceGroup string
// param functionSubscriptionId string
// param functionResourceGroup string

module provision './provision/provision.bicep' = {
  name: 'provisionResources'
  params: {
    teamsFxProvisionParameters: provisionParameters
  }
}



module teamsFxBotConfig './teamsFxConfiguration/teamsFxBotConfig.bicep' = {
  name: 'teamsFxBotConfig'
  // scope: resourceGroup(provision.outputs.fxBotPluginOutput.webAppSubscriptionId, provision.outputs.fxBotPluginOutput.webAppResourceGroup)
  // scope: resourceGroup(botSubscriptionId, botResourceGroup)
  params: {
    provisionOutputs: provision.outputs
  }
}

module teamsFxFunctionConfig './teamsFxConfiguration/teamsFxFunctionConfig.bicep' = {
  name: 'teamsFxFunctionConfig'
  // scope: resourceGroup(provision.outputs.fxFunctionPluginOutput.functionAppSubscriptionId, provision.outputs.fxFunctionPluginOutput.functionAppResourceGroup)
  // scope: resourceGroup(functionSubscriptionId, functionResourceGroup)
  params: {
    provisionOutputs: provision.outputs
  }
}
