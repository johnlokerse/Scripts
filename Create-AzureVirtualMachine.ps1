# Azure Settings
[string] $resourceGroupName = "rg-john"
[string] $location = "WestEurope"

# Virtual Machine Related Settings
[string] $osName = "centos"
[string] $virtualMachineName = "$osName-vps-euw-webserver"
[string] $vmSize = "Standard_B2s"
[string] $vnetName = "$osName-vnet"
[string] $subnetName = "$osName-subnet"
[string] $publicIPName = "$osName-publicip"
[string] $networkSecurityGroupName = "$osName-nsg"
[string] $nicName = "$osName-nic"

try {
    # Create Resource Group
    az group create --location $location --resource-group $resourceGroupName

    # Create a VNET
    az network vnet create --name $vnetName --subnet-name $subnetName --resource-group $resourceGroupName

    # Create a Public IP
    az network public-ip create --name $publicIPName --resource-group $resourceGroupName

    # Create a NSG
    az network nsg create --name $networkSecurityGroupName --resource-group $resourceGroupName

    # Create a NIC
    az network nic create --name $nicName --vnet-name $vnetName --subnet $subnetName --network-security-group $networkSecurityGroupName --public-ip-address $publicIPName --resource-group $resourceGroupName

    # Create VM
    az vm create --name $virtualMachineName --size $vmSize --nics $nicName --image $osName --admin-username "john" --authentication-type "ssh" --generate-ssh-keys --resource-group $resourceGroupName

    # Open SSH port
    az vm open-port --port 22 --name $virtualMachineName --resource-group $resourceGroupName --priority 150 --nsg-name $networkSecurityGroupName
    az vm open-port --port 80 --name $virtualMachineName --resource-group $resourceGroupName --priority 175 --nsg-name $networkSecurityGroupName
}
catch {
    az group delete --resource-group $resourceGroupName --yes
}

# Clean up if failed
if ($LASTEXITCODE -ne 0) {
    Write-Error "Something failed... cleaning up..."
    az group delete --resource-group $resourceGroupName --yes
}