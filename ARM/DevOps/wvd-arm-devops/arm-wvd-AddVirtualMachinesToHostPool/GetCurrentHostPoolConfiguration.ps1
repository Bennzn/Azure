# used from https://azuretigers.com/windows-virtual-desktop-image-management-automated-part-3-create-wvd-sessionhosts-on-image-version-with-arm/

import-module az.desktopvirtualization
import-module az.network
import-module az.compute
import-module az.resources

$existingWVDHostPoolName = $args[0]
#$existingResourceGroup = $args[0]
#$existingWVDHostPoolName = "HP-WVD-Win10-20h2"
#$existingResourceGroup = "RG-WVD-Test"

# Get the hostpool information
$hostpool = Get-AzWvdHostPool | ? { $_.Name -eq $existingWVDHostPoolName }
#$hostpool = Get-AzWvdHostPool -Name $existingWVDHostPoolName -ResourceGroupName $existingResourceGroup
$resourceGroup = ($hostpool).id.split("/")[4].ToUpper()
$hostpoolSubscription = ($hostpool).id.split("/")[2]
# Get current sessionhost information
$sessionHosts = Get-AzWvdSessionHost -ResourceGroupName $resourceGroup -HostPoolName $hostpool.name
#$sessionHosts = Get-AzWvdSessionHost -ResourceGroupName $existingResourceGroup -HostPoolName $hostpool.Name

# Doing some checks beforce continuing
if ($null -eq $sessionHosts) {
    Write-Host "No sessionhosts found in hostpool $hostpoolname, exiting script"
    exit;
}

#if ($null -eq $sessionHostsNumber) {
#    $sessionHostsNumber = $sessionHosts.count
#    Write-Host "No sessionHostsNumber provided, creating $sessionHostsNumber hosts"
#}

# Get current sessionhost configuration, used in the next steps
$existingHostName = $sessionHosts[-1].Name.Split("/")[-1]
$existingHostName = $existingHostName.Split(".")[0]
Write-Host "Current Hostname is $existingHostname"
#$prefix = $existingHostName.Trim("-")[10]
$prefix = $existingHostName.Substring(0, $existingHostName.LastIndexOf('-'))
Write-Host "Current prefix is $prefix"
$currentVmInfo = Get-AzVM -name $existingHostName
$vmInitialNumber = ([int]$existingHostName.Split("-")[-1]) + 1
Write-Host "Current vmInitialNumber is $vmInitialNumber"
$vmNetworkInformation = (Get-AzNetworkInterface -ResourceId $currentVmInfo.NetworkProfile.NetworkInterfaces.id)
$virtualNetworkName = $vmNetworkInformation.IpConfigurations.subnet.id.split("/")[-3]
Write-Host "Current virtualNetworkName is $virtualNetworkName"
$virutalNetworkResoureGroup = $vmNetworkInformation.IpConfigurations.subnet.id.split("/")[4]
Write-Host "Current virutalNetworkResoureGroup is $virutalNetworkResoureGroup"
$virtualNetworkSubnet = $vmNetworkInformation.IpConfigurations.subnet.id.split("/")[-1]
Write-Host "Current virtualNetworkSubnet is $virtualNetworkSubnet"


# Get the image gallery information for getting latest image
$imageReference = ($currentVmInfo.storageprofile.ImageReference).id
Write-Host "Current imageReference is $imageReference"

if (!$imageReference){
    Write-Host "Current imageReference not available!"
} else {

    $galleryImageDefintion = get-AzGalleryImageDefinition -ResourceId $imageReference
    #Write-Host "Current galleryImageDefintion is $galleryImageDefintion"
    $galleryName = $imageReference.Split("/")[-3]
    $gallery = Get-AzGallery -Name $galleryName
    $latestImageVersion = (Get-AzGalleryImageVersion -ResourceGroupName $gallery.ResourceGroupName -GalleryName $gallery.Name -GalleryImageDefinitionName $galleryImageDefintion.Name)[-1]

}

Write-Host "$("##vso[task.setvariable variable=vmInitialNumber]")$($vmInitialNumber)"
Write-Host "$("##vso[task.setvariable variable=prefix]")$($prefix)"
