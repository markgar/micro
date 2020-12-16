var unqStr = substring(uniqueString(resourceGroup().id), 0, 3)

resource asp 'Microsoft.Web/serverfarms@2020-06-01' = {
  location: resourceGroup().location
  name: 'micro-asp-${unqStr}'
  sku: {
    name: 'S1'
  }
}

resource catalogWeb 'Microsoft.Web/sites@2020-06-01' = {
  location: resourceGroup().location
  name: 'micro-catalog-web-${unqStr}'
  properties: {
    serverFarmId: asp.id
    siteConfig: {
      appSettings: [
        {
          name: 'ConnectionStrings:AppConfig'
          value: 'PLEASE_FILL'
        }
      ]
    }
  }
}

resource cartWeb 'Microsoft.Web/sites@2020-06-01' = {
  location: resourceGroup().location
  name: 'micro-cart-web-${unqStr}'
  properties: {
    serverFarmId: asp.id
    siteConfig: {
      appSettings: [
        {
          name: 'ConnectionStrings:AppConfig'
          value: 'PLEASE_FILL'
        }
      ]
    }
  }
}

resource cosmos 'Microsoft.DocumentDB/databaseAccounts@2020-04-01' = {
  location: resourceGroup().location
  name: 'micro-cosmos-${unqStr}'
  properties: {
    databaseAccountOfferType: 'Standard'
    locations: [
      {
        locationName: 'East Us'
      }
    ]
  }
}

resource appInsights 'Microsoft.Insights/components@2015-05-01' = {
  kind: 'web'
  name: 'micro-appinsights-${unqStr}'
  location: resourceGroup().location
  properties: {
    RetentionInDays: 90
  }
}

resource logAnalytics 'Microsoft.OperationalInsights/workspaces@2020-08-01' = {
  location: resourceGroup().location
  name: 'micro-loga-${unqStr}'
  properties: {
    sku: {
      name: 'PerGB2018'
    }
  }
}

resource configSvcs 'Microsoft.AppConfiguration/configurationStores@2020-06-01' = {
  location: resourceGroup().location
  name: 'micro-appcfg-${unqStr}'
  sku: {
    name: 'standard'
  }
}

resource configDbName 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${configSvcs.name}/CosmosDb:DatabaseName'
  properties: {
    value: 'micro'
  }
}

resource configDbKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${configSvcs.name}/CosmosDb:Key'
  properties: {
    value: 'PLEASE FILL'
  }
}

resource configDbAcct 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${configSvcs.name}/CosmosDb:Account'
  properties: {
    value: '${cosmos.properties.documentEndpoint}'
  }
}

resource configSvcUrl 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${configSvcs.name}/CatalogItemServiceUrl'
  properties: {
    value: '${catalogWeb.properties.hostNames[0]}'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: 'micro-vnet-${unqStr}'
  location: resourceGroup().location
  properties: {
    addressSpace:{
      addressPrefixes:[
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet1'
        properties: {
          addressPrefix: '10.0.0.0/24'
        }
      }
    ]
  }
}

resource pip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: 'micro-pip-${unqStr}'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
  }
}

resource nInter 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: 'micro-nic-${unqStr}'
  location: resourceGroup().location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: pip.id
          }
          subnet: {
            id: '${vnet.properties.subnets[0].id}'
          }
        }
      }
    ]
  }
}