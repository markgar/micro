param adminUserName string {
  secure: true
}

param adminPassword string {
  secure: true
}

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
    // siteConfig: {
    //   appSettings: [
    //     {
    //       name: 'ConnectionStrings:AppConfig'
    //       value: 'PLEASE_FILL'
    //     }
    //   ]
    // }
  }
}

resource cartWeb 'Microsoft.Web/sites@2020-06-01' = {
  location: resourceGroup().location
  name: 'micro-cart-web-${unqStr}'
  properties: {
    serverFarmId: asp.id
    // siteConfig: {
    //   appSettings: [
    //     {
    //       name: 'ConnectionStrings:AppConfig'
    //       value: 'PLEASE_FILL'
    //     }
    //   ]
    // }
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
    Application_Type: 'web'
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

// resource configDbKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
//   name: '${configSvcs.name}/CosmosDb:Key'
//   properties: {
//     value: 'PLEASE FILL'
//   }
// }

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

resource configAppInsightsKey 'Microsoft.AppConfiguration/configurationStores/keyValues@2020-07-01-preview' = {
  name: '${configSvcs.name}/ApplicationInsights:InstumentationKey'
  properties: {
    value: '${appInsights.properties.InstrumentationKey}'
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2020-06-01' = {
  name: 'micro-vnet-${unqStr}'
  location: resourceGroup().location
  properties: {
    addressSpace: {
      addressPrefixes: [
        '10.0.0.0/16'
      ]
    }
    subnets: [
      {
        name: 'subnet'
        properties: {
          addressPrefix: '10.0.1.0/24'
        }
      }
    ]
  }
}

resource catalogVmPip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: 'micro-catalog-pip-${unqStr}'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: 'catalog-${unqStr}'
    }
  }
}

resource catalogVmNic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: 'micro-catalog-nic-${unqStr}'
  location: resourceGroup().location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: catalogVmPip.id
          }
          subnet: {
            id: '${vnet.id}/subnets/subnet'
          }
        }
      }
    ]
  }
}

resource catalogVm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: 'micro-catalog-vm-${unqStr}'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    osProfile: {
      computerName: 'micro-catalog'
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: 'micro-catalog-vm-${unqStr}-OSDISK'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: catalogVmNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource cartVmPip 'Microsoft.Network/publicIPAddresses@2020-06-01' = {
  name: 'micro-cart-pip-${unqStr}'
  location: resourceGroup().location
  properties: {
    publicIPAllocationMethod: 'Dynamic'
    dnsSettings: {
      domainNameLabel: 'cart-${unqStr}'
    }
  }
}

resource cartVmNic 'Microsoft.Network/networkInterfaces@2020-06-01' = {
  name: 'micro-cart-nic-${unqStr}'
  location: resourceGroup().location

  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: cartVmPip.id
          }
          subnet: {
            id: '${vnet.id}/subnets/subnet'
          }
        }
      }
    ]
  }
}

resource cartVm 'Microsoft.Compute/virtualMachines@2020-06-01' = {
  name: 'micro-cart-vm-${unqStr}'
  location: resourceGroup().location
  properties: {
    hardwareProfile: {
      vmSize: 'Standard_D2s_v3'
    }
    osProfile: {
      computerName: 'micro-cart'
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
        offer: 'WindowsServer'
        sku: '2019-Datacenter'
        version: 'latest'
      }
      osDisk: {
        name: 'micro-cart-vm-${unqStr}-OSDISK'
        caching: 'ReadWrite'
        createOption: 'FromImage'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: cartVmNic.id
        }
      ]
    }
    diagnosticsProfile: {
      bootDiagnostics: {
        enabled: false
      }
    }
  }
}

resource cartShutdown 'Microsoft.DevTestLab/schedules@2018-09-15' = {
  name: 'shutdown-computevm-micro-cart-vm-${unqStr}'
  location: resourceGroup().location
  properties: {
    dailyRecurrence: {
      time: '2200'
    }
    timeZoneId: 'Central Standard Time'
    taskType: 'ComputeVmShutdownTask'
    targetResourceId: cartVm.id
    status: 'Enabled'
    notificationSettings: {
      status: 'Disabled'
      timeInMinutes: 30
      notificationLocale: 'en'
    }
  }
}