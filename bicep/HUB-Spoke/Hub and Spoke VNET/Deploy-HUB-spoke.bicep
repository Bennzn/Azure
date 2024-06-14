targetScope = 'subscription' 

param location string = 'northeurope'
param rgNameHUB string = 'rg-networking-hub-neu-01'
param rgNameSpoke string = 'rg-networking-spoke-neu-01'
param responsibleTag string = 'Benjamin Graus'
param costCenterTag string = 'PSPC'

//HUB VNET Parameters
param vnetHubName string = 'vnet-hub-neu-01'
param vnetHubSuffix string = '10.240.0.0/24'
param subnetHubFEName string = 'snet-fe-hub-neu-01'
param subnetHubBEName string = 'snet-be-hub-neu-01'
param subnetHubFESuffix string = '10.240.0.0/27'
param subnetHubBESuffix string = '10.240.0.32/27'
param locationHub string = 'northeurope'

//Spoke VNET Parameters
param locationSpoke string = 'northeurope'
param vnetSpokeName string = 'vnet-spoke-neu-01'
param vnetSpokeSuffix string = '10.89.0.0/24'
param subnetSpokeName string = 'snet-spoke-neu-01'
param subnetSpokeSuffix string = '10.89.0.0/24'
param rtName string = 'rt-spoke-neu-01'



resource rgHUB 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: rgNameHUB
  location: location
  tags: {
    Responsible: responsibleTag
    CostCenter: costCenterTag
  }
}

resource rgSpoke 'Microsoft.Resources/resourceGroups@2023-07-01' = {
  name: rgNameSpoke
  location: location
  tags: {
    Responsible: responsibleTag
    CostCenter: costCenterTag
  }
}

module createHUB 'create_HUB.bicep' = {
  name: 'NetworkHUB'
  scope: rgHUB
  params: {
    locationHub: locationHub
    costCenterTag: costCenterTag
    responsibleTag: responsibleTag
    subnetHubFEName: subnetHubFEName
    subnetHubBEName: subnetHubBEName
    subnetHubFESuffix: subnetHubFESuffix
    subnetHubBESuffix: subnetHubBESuffix
    vnetHubName: vnetHubName
    vnetHubSuffix: vnetHubSuffix
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
    createHUB
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
    createHUB
    createSpokeHubPeering
  ]
}
