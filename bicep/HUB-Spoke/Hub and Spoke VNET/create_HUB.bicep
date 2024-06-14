param locationHub string
param vnetHubName string
param vnetHubSuffix string
param subnetHubBESuffix string
param subnetHubFESuffix string
param subnetHubFEName string
param subnetHubBEName string
param responsibleTag string
param costCenterTag string


resource vnet 'Microsoft.Network/virtualNetworks@2023-06-01' = {
  name: vnetHubName
  location: locationHub
  tags: {
    Responsible: responsibleTag
    CostCenter: costCenterTag
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetHubSuffix
      ]
    }
  
    subnets: [
      {
        name: subnetHubFEName
        properties: {
          addressPrefix: subnetHubFESuffix
        }
      }
      {
        name: subnetHubBEName
        properties: {
          addressPrefix: subnetHubBESuffix
        }
      }
    ]
  }
}

