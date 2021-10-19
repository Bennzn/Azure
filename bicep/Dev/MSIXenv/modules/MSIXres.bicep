param location string = 'westeurope'
param networkInterfaceName string = '${virtualMachineName}-nic'
param networkSecurityGroupName string = '${virtualMachineName}-nsg'
//param networkSecurityGroupRules array 
param subnetName string = 'SNET-WVD-Research-WEU'
param virtualNetworkId string = '/subscriptions/157f3366-50f1-48c4-bae0-17de1998d98f/resourceGroups/RG-WVD-Test/providers/Microsoft.Network/virtualNetworks/VNET-WVD-WEU'
param publicIpAddressName string = '${virtualMachineName}-pip'
param publicIpAddressType string = 'dynamic'
param publicIpAddressSku string = 'Basic'
param virtualMachineName string = 'MSIX-01'
param virtualMachineComputerName string = 'MSIX-01'
//param virtualMachineRG string
param osDiskType string = 'StandardSSD_LRS'
param virtualMachineSize string = 'Standard_D2_v2'
@secure()
param localAdmin string

@secure()
param localAdminPassword string


var nsgId = resourceId(resourceGroup().name, 'Microsoft.Network/networkSecurityGroups', networkSecurityGroupName)
var vnetId = virtualNetworkId
var subnetRef = '${vnetId}/subnets/${subnetName}'

resource networkInterfaceName_resource 'Microsoft.Network/networkInterfaces@2018-10-01' = {
  name: networkInterfaceName
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          subnet: {
            id: subnetRef
          }
          privateIPAllocationMethod: 'Dynamic'
          publicIPAddress: {
            id: resourceId(resourceGroup().name, 'Microsoft.Network/publicIpAddresses', publicIpAddressName)
          }
        }
      }
    ]
    networkSecurityGroup: {
      id: nsgId
    }
    dnsSettings: {
      dnsServers: [
        '1.1.1.1'
      ]
    }
  }
  dependsOn: [
    networkSecurityGroupName_resource
    publicIpAddressName_resource
  ]
}

resource networkSecurityGroupName_resource 'Microsoft.Network/networkSecurityGroups@2019-02-01' = {
  name: networkSecurityGroupName
  location: location
  properties: {
    //securityRules: networkSecurityGroupRules
    securityRules: [
      {
        name: 'RDP'
        properties: {
          priority: 300
          protocol: 'Tcp'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '*'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '3389'
        }
      }
      {
        name: 'Allow_ResearchNetwork'
        properties: {
          priority: 310
          protocol: '*'
          access: 'Allow'
          direction: 'Inbound'
          sourceAddressPrefix: '10.105.10.0/24'
          sourcePortRange: '*'
          destinationAddressPrefix: '*'
          destinationPortRange: '*'
        }
      }
    ]
  }
}

resource publicIpAddressName_resource 'Microsoft.Network/publicIpAddresses@2019-02-01' = {
  name: publicIpAddressName
  location: location
  properties: {
    publicIPAllocationMethod: publicIpAddressType
  }
  sku: {
    name: publicIpAddressSku
  }
}

resource virtualMachineName_resource 'Microsoft.Compute/virtualMachines@2021-03-01' = {
  name: virtualMachineName
  location: location
  properties: {
    hardwareProfile: {
      vmSize: virtualMachineSize
    }
    storageProfile: {
      osDisk: {
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: osDiskType
        }
      }
      imageReference: {
        publisher: 'MicrosoftWindowsDesktop'
        offer: 'Windows-10'
        sku: '21h1-evd'
        version: 'latest'
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterfaceName_resource.id
        }
      ]
    }
    osProfile: {
      computerName: virtualMachineComputerName
      adminUsername: localAdmin
      adminPassword: localAdminPassword
      windowsConfiguration: {
        enableAutomaticUpdates: true
        provisionVMAgent: true
      }
    }
    licenseType: 'Windows_Client'
  }
}

output localAdmin string = localAdmin
