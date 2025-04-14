/*
------------------
param section
------------------
*/
param location string
param BastionVNetName string 
param BastionVNetAddress string
// VM Subnet
param BastionSubnetName1 string
param BastionSubnetAddress1 string
param BastionSubnetName2 string
param BastionSubnetAddress2 string
// for VM
param BastionvmName1 string
param BastionvmName2 string
param vmSizeWindows string
param vmSizeLinux string
@secure()
param adminUserName string
@secure()
param adminPassword string

/*
------------------
var section
------------------
*/
// VM Subnet
var BastionSubnet1 = { 
  name: BastionSubnetName1 
  properties: { 
    addressPrefix: BastionSubnetAddress1
    networkSecurityGroup: {
    id: nsg.id
    }
  }
}

var BastionSubnet2 = { 
  name: BastionSubnetName2 
  properties: { 
    addressPrefix: BastionSubnetAddress2
    networkSecurityGroup: {
    id: nsg.id
    }
  }
}

/*
------------------
resource section
------------------
*/

// create network security group for Bastion vnet
resource nsg 'Microsoft.Network/networkSecurityGroups@2023-04-01' = {
  name: '${BastionVNetName}-nsg'
  location: location
  //properties: {
  //  securityRules: [
  //    {
  //      name: 'Allow-SSH'
  //      properties: {
  //      description: 'SSH access permission from your own PC.'
  //      protocol: 'TCP'
  //      sourcePortRange: '*'
  //      destinationPortRange: '22'
  //      sourceAddressPrefix: '*'
  //      destinationAddressPrefix: '*'
  //      access: 'Allow'
  //      priority: 1000
  //      direction: 'Inbound'
  //      }
  //    }
  //  ]
  //}
}

// create BastionVNet & BastionSubnet
resource BastionVNet 'Microsoft.Network/virtualNetworks@2021-05-01' = { 
  name: BastionVNetName 
  location: location 
  properties: { 
    addressSpace: { 
      addressPrefixes: [ 
        BastionVNetAddress 
      ] 
    } 
    subnets: [ 
      BastionSubnet1
      BastionSubnet2
    ]
  }
  // Get subnet information where VMs are connected.
  resource BastionVMSubnet1 'subnets' existing = {
    name: BastionSubnetName1
  }
  resource BastionVMSubnet2 'subnets' existing = {
    name: BastionSubnetName2
  }
}

// create VM in BastionVNet
// create network interface for Linux VM
resource networkInterface1 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: '${BastionvmName1}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: BastionVNet::BastionVMSubnet1.id
          }
        }
      }
    ]
  }
}

// create Linux vm in VMSubnet
resource centosVM1 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: BastionvmName1
  location: location
  plan: {
    name: 'centos-8-0-free'
    publisher: 'cognosys'
    product: 'centos-8-0-free'
  }
  properties: {
    hardwareProfile: {
      vmSize: vmSizeLinux
    }
    osProfile: {
      computerName: BastionvmName1
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'cognosys'
       offer: 'centos-8-0-free'
        sku: 'centos-8-0-free'
        version: 'latest'
      }
      osDisk: {
        name: '${BastionvmName1}-disk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface1.id
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

// create network interface for Windows VM
resource networkInterface2 'Microsoft.Network/networkInterfaces@2023-04-01' = {
  name: '${BastionvmName2}-nic'
  location: location
  properties: {
    ipConfigurations: [
      {
        name: 'ipconfig1'
        properties: {
          privateIPAllocationMethod: 'Dynamic'
          subnet: {
            id: BastionVNet::BastionVMSubnet2.id
          }
        }
      }
    ]
  }
}

// create Windows vm in Bastion vnet
resource windowsVM1 'Microsoft.Compute/virtualMachines@2023-03-01' = {
  name: BastionvmName2
  location: location
  properties: {
    hardwareProfile: {
      vmSize: vmSizeWindows
    }
    osProfile: {
      computerName: BastionvmName2
      adminUsername: adminUserName
      adminPassword: adminPassword
    }
    storageProfile: {
      imageReference: {
        publisher: 'MicrosoftWindowsServer'
       offer: 'WindowsServer'
        sku: '2022-datacenter-azure-edition'
        version: 'latest'
      }
      osDisk: {
        name: '${BastionvmName2}-disk'
        caching: 'ReadWrite'
        createOption: 'FromImage'
        managedDisk: {
          storageAccountType: 'Standard_LRS'
        }
      }
    }
    networkProfile: {
      networkInterfaces: [
        {
          id: networkInterface2.id
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

/*
------------------
output section
------------------
*/

// return the private ip address of the vm to use from parent template
@description('return the private ip address of the vm to use from parent template')
output vmPrivateIp1 string = networkInterface1.properties.ipConfigurations[0].properties.privateIPAddress
output vmPrivateIp2 string = networkInterface2.properties.ipConfigurations[0].properties.privateIPAddress
