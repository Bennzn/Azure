targetScope = 'subscription' 

param location string = 'italynorth'
param responsibleTag string = 'Benjamin Graus'
param costCenterTag string = 'PSPC'

//HUB VNET Parameters
param vnetHubName string = 'vnet-hub-ita-01'
param rgNameHUB string = 'rg-networking-hub-ita-01'

//Spoke VNET Parameters
param locationSpoke string = 'italynorth'
param rgNameSpoke string = 'rg-networking-spoke-ita-04'
param vnetSpokeName string = 'vnet-spoke-ita-04'
param vnetSpokeSuffix string = '10.97.0.0/24'
param subnetSpokeName string = 'snet-spoke-ita-04'
param subnetSpokeSuffix string = '10.97.0.0/24'

//RouteTable Parameters
param rtName string = 'rt-spoke-ita-04'
param rtNextHopIP string = '10.250.0.36'


resource rgSpoke 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: rgNameSpoke
  location: location
  tags: {
    Responsible: responsibleTag
    CostCenter: costCenterTag
  }
}

module createSpoke 'create_Spoke.bicep' = {
  name: 'NetworkSpoke'
  scope: rgSpoke
  params: {
    costCenterTag: costCenterTag
    locationSpoke: locationSpoke
    responsibleTag: responsibleTag
    rtName: rtName
    rtNextHopIP: rtNextHopIP
    subnetSpokeName: subnetSpokeName
    subnetSpokeSuffix: subnetSpokeSuffix
    vnetSpokeName: vnetSpokeName
    vnetSpokeSuffix: vnetSpokeSuffix
  }
}

module createSpokeHubPeering 'create_peering.bicep' = {
  name: 'PeerSpokeToHub'
  scope: resourceGroup(rgNameSpoke)
  params: {
    PeerVnetLocalName: vnetSpokeName
    PeerVnetRemoteName: vnetHubName
    PeerRemoteRG: rgNameHUB
  }
  dependsOn: [
    createSpoke
  ]
}

module createHubSpokePeering 'create_peering.bicep' = {
  name: 'PeerHubToSpoke'
  scope: resourceGroup(rgNameHUB)
  params: {
    PeerVnetLocalName: vnetHubName
    PeerVnetRemoteName: vnetSpokeName
    PeerRemoteRG: rgNameSpoke
  }
  dependsOn: [
    createSpoke
    createSpokeHubPeering
  ]
}



