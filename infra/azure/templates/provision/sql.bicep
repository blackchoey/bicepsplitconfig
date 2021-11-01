@secure()
param provisionParameters object

var resourceBaseName = provisionParameters['resourceBaseName']
var administratorLogin = provisionParameters['azureSqlAdmin']
var administratorLoginPassword = provisionParameters['azureSqlAdminPassword']
var sqlServerName = contains(provisionParameters, 'azureSqlServerName') ? provisionParameters['azureSqlServerName'] : '${resourceBaseName}'
var sqlDatabaseName = contains(provisionParameters, 'azureSqlDatabaseName') ? provisionParameters['azureSqlDatabaseName'] : '${resourceBaseName}'

resource sqlServer 'Microsoft.Sql/servers@2021-05-01-preview' = {
  location: resourceGroup().location
  name: sqlServerName
  properties: {
    administratorLogin: administratorLogin
    administratorLoginPassword: administratorLoginPassword
  }
}

resource sqlDatabase 'Microsoft.Sql/servers/databases@2021-05-01-preview' = {
  parent: sqlServer
  location: resourceGroup().location
  name: sqlDatabaseName
  sku: {
    name: 'Basic'
  }
}

resource sqlFirewallRules 'Microsoft.Sql/servers/firewallRules@2021-05-01-preview' = {
  parent: sqlServer
  name: 'AllowAzure'
  properties: {
    endIpAddress: '0.0.0.0'
    startIpAddress: '0.0.0.0'
  }
}

output sqlServerResourceId string = sqlServer.id
output sqlServerEndpoint string = sqlServer.properties.fullyQualifiedDomainName
output sqlDatabaseName string = sqlDatabaseName
