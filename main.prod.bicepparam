using 'main.bicep'

param resourceGroupName = 'Bastion-Dev-RG'
param resourceGroupLocation = 'japaneast'
// ---- param for Bastion VNet----
param BastionVNetName = 'Bastion-VNet' 
param BastionVNetAddress = '10.0.0.0/16'
param BastionSubnetName1 = 'B-LinuxSubnet'
param BastionSubnetAddress1 = '10.0.1.0/24'
param BastionSubnetName2 = 'B-WinSubnet'
param BastionSubnetAddress2 = '10.0.2.0/24'
param BastionvmName1 = 'B-Linux'
param BastionvmName2 = 'B-Win2k22'
// ---- Common param for VM ----
param vmSizeLinux = 'Standard_B2s'
param vmSizeWindows = 'Standard_B2ms'
param adminUserName = 'cloudadmin'
param adminPassword = 'msjapan1!msjapan1!'
