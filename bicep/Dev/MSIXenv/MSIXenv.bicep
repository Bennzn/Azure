targetScope = 'subscription'
param resourceGroupPrefix string = 'RG-AVD-MSIX'
param location string = 'westeurope'
param networkInterfaceName string
param networkSecurityGroupName string
param networkSecurityGroupRules array
param subnetName string
param virtualNetworkId string
param publicIpAddressName string
param publicIpAddressType string
param publicIpAddressSku string
param virtualMachineName string
param virtualMachineComputerName string
param virtualMachineRG string
param osDiskType string
param virtualMachineSize string

@secure()
param localAdmin string

@secure()
param localAdminPassword string



//Define Networking deployment parameters
param vnetName string = 'msix-vnet'
param vnetaddressPrefix string ='10.0.0.0/15'
param subnetPrefix string = '10.0.1.0/24'
param vnetLocation string = 'westeurope'
param subnetName string = 'msix-subnet'

resource rgMSIX 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: resourceGroupPrefix
  location: location
}

module VMMSIX './modules/MSIXres.bicep' = {
  name: virtualMachineName
  scope: resourceGroup(rgMSIX.name) 
  params: {
    virtualMachineName: virtualMachineName
    localAdmin: localAdmin
    localAdminPassword: localAdminPassword
    location: location
  }  
}
