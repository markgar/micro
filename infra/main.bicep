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
  }
}

resource cartWeb 'Microsoft.Web/sites@2020-06-01' = {
  location: resourceGroup().location
  name: 'micro-cart-web-${unqStr}'
  properties: {
    serverFarmId: asp.id
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
    Application_Type: 'web'
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