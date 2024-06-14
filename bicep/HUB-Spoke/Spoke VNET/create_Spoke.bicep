
param locationSpoke string
param vnetSpokeName string
param vnetSpokeSuffix string
param subnetSpokeName string
param subnetSpokeSuffix string
param rtName string
param rtNextHopIP string
//param hubVnetId string = '/subscriptions/da59d007-3a01-42aa-8ea8-00bd3e12566c/resourceGroups/RG-Networking-HUB-ITA/providers/Microsoft.Network/virtualNetworks/vnet-hub-ita-01'
param responsibleTag string
param costCenterTag string



resource vnetSpoke 'Microsoft.Network/virtualNetworks@2023-06-01' = {
  name: vnetSpokeName
  location: locationSpoke
  tags: {
    Responsible: responsibleTag
    CostCenter: costCenterTag
  }
  properties: {
    addressSpace: {
      addressPrefixes: [
        vnetSpokeSuffix
      ]
    }
  }
}

resource rt 'Microsoft.Network/routeTables@2023-06-01' = {
  name: rtName
  location: locationSpoke
  properties: {
    disableBgpRoutePropagation: false
    routes: [
      {
        name: 'default'
        properties: {
          addressPrefix: '0.0.0.0/0'
          nextHopType: 'VirtualAppliance'
          nextHopIpAddress: rtNextHopIP
        }
      }
    ]
  }
}

resource subnetSpoke 'Microsoft.Network/virtualNetworks/subnets@2023-06-01' = {
  name: subnetSpokeName
  parent: vnetSpoke
  properties: {
    addressPrefix: subnetSpokeSuffix
    routeTable: {
      id: rt.id
    }
  }
}



// resource subnetRouteAssociation 'Microsoft.Network/virtualNetworks/subnets/routeTables@2023-04-01' = {
//   name: '${vnetSpokeName}/${subnetSpokeName}/${rtName}'
//   properties: {
//     routeTable: {
//       id: rt.id
//     }
//   }
//   dependsOn: [
//     vnetSpoke
//     subnetSpoke
//   ]
// }





