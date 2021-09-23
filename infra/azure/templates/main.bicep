@secure()
param provisionParameters object

module provision './provision/provision.bicep' = {
  name: 'provisionResources'
  params: {
    provisionParameters: provisionParameters
  }
}

module teamsFxBotConfig './teamsFxConfiguration/teamsFxBotConfiguration.bicep' = {
  name: 'addTeamsFxBotConfiguration'
  params: {
    provisionParameters: provisionParameters
    provisionOutputs: provision.outputs
  }
}

module teamsFxFunctionConfig './teamsFxConfiguration/teamsFxFunctionConfiguration.bicep' = {
  name: 'addTeamsFxFunctionConfiguration'
  params: {
    provisionParameters: provisionParameters
    provisionOutputs: provision.outputs
  }
}
