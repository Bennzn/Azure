param PeerRemoteRG string
param PeerVnetLocalName string
param PeerVnetRemoteName string
param PeeringName string = '${PeerVnetLocalName}-To-${PeerVnetRemoteName}'


resource createVnetPeering 'Microsoft.Network/virtualNetworks/virtualNetworkPeerings@2023-06-01' = {
  name: '${PeerVnetLocalName}/${PeeringName}'
  properties: {
    remoteVirtualNetwork: {
      id: resourceId(PeerRemoteRG, 'Microsoft.Network/virtualNetworks', PeerVnetRemoteName)
    }
    allowVirtualNetworkAccess: true
    allowForwardedTraffic: true
    allowGatewayTransit: false
    useRemoteGateways: false
  }
  dependsOn: [
    
  ]
}
