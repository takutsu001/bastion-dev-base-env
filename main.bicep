targetScope = 'subscription'

/*
------------------
param section
------------------
*/
// ---- param for Common ----
param resourceGroupName string
param resourceGroupLocation string

// ---- param for Onpre ----
param BastionVNetName string 
param BastionVNetAddress string
// VM Subnet
param BastionSubnetName1 string
param BastionSubnetAddress1 string
param BastionSubnetName2 string
param BastionSubnetAddress2 string

// ----param for VM----
param vmSizeLinux string
param vmSizeWindows string
param BastionvmName1 string
param BastionvmName2 string
@secure()
param adminUserName string
@secure()
param adminPassword string

/*
------------------
resource section
------------------
*/

resource newRG 'Microsoft.Resources/resourceGroups@2021-04-01' = { 
  name: resourceGroupName 
  location: resourceGroupLocation 
} 

/*
---------------
module section
---------------
*/

// Create Onpre Environment (VM-Windows, VNet, Subnet, NSG)
module BastionModule './modules/BastionEnv.bicep' = { 
  scope: newRG 
  name: 'CreateBastinEnv' 
  params: { 
    location: resourceGroupLocation
    BastionVNetName: BastionVNetName
    BastionVNetAddress: BastionVNetAddress
    BastionSubnetName1: BastionSubnetName1
    BastionSubnetAddress1: BastionSubnetAddress1
    BastionSubnetName2: BastionSubnetName2
    BastionSubnetAddress2: BastionSubnetAddress2
    BastionvmName1: BastionvmName1
    BastionvmName2: BastionvmName2
    vmSizeLinux: vmSizeLinux
    vmSizeWindows: vmSizeWindows
    adminUserName: adminUserName
    adminPassword: adminPassword
  } 
}
