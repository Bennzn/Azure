# Used from https://github.com/danielsollondon/azvmimagebuilder/tree/master/quickquickstarts/2_Creating_a_Custom_Win_Shared_Image_Gallery_Image_from_SIG
# Image Builder Customize existing SIG Template to SIG Template

#Connect to Azure
Connect-AzAccount

# Step 1: Import module
Import-Module Az.Accounts

# Step 2: get existing context
$currentAzContext = Get-AzContext

# destination image resource group
$imageResourceGroup="RG-WVD-ImageBuilder"

# location (see possible locations in main docs)
$location="westeurope"

# your subscription, this will get your current subscription
$subscriptionID=$currentAzContext.Subscription.Id

# name of the image to be created
$imageName="imageBuilderCustomW2k19v2"

# image template name
$imageTemplateName="imageBuilderCustomTemplateW2k19v2"

# distribution properties object name (runOutput), i.e. this gives you the properties of the managed image on completion
$runOutputName="imageBuilderCustomW2k19v2"

$sigGalleryName= "imagebuilder_sig"
$imageDefName ="IB-CustomW2k19"

# additional replication region
#$replRegion2="eastus"

################################# Create user identity or use previous identity

# setup role def names, these need to be unique
$idenityObject=$(Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup | Where-Object {$_.Name -Match "ImageBuilderIdentityDev"})


$idenityNameResourceId=$idenityObject.Id
$idenityNamePrincipalId=$idenityObject.PrincipalId
$idenityName=$idenityObject.Name

############################# Get latest image version for source

# get all versions from SIG def
$getAllImageVersions=$(Get-AzGalleryImageVersion -ResourceGroupName $imageResourceGroup  -GalleryName $sigGalleryName -GalleryImageDefinitionName $imageDefName)

# get name and expand publishing date for a version
$versionPubList=$($getAllImageVersions | Select-Object -Property Name -ExpandProperty PublishingProfile)

# order by published date (leaving in more columns for induvidual validation)
$sortedVersionList=$($versionPubList | Select-Object Name, PublishedDate | Sort-Object PublishedDate -Descending | Select-Object Name -First 1)

# get latest version resource id
$sigDefImgVersionId=$(Get-AzGalleryImageVersion -ResourceGroupName $imageResourceGroup  -GalleryName $sigGalleryName -GalleryImageDefinitionName $imageDefName -Name $sortedVersionList.name).Id

############################## Configure the Image Template

$templateUrl="https://raw.githubusercontent.com/Bennzn/Azure/master/ARM/ImageBuilder/SIGtoSIG/armIB-SIGtoSIG.json"
$templateFilePath = "armIB-SIGtoSIG.json"

Invoke-WebRequest -Uri $templateUrl -OutFile $templateFilePath -UseBasicParsing

((Get-Content -path $templateFilePath -Raw) -replace '<subscriptionID>',$subscriptionID) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<rgName>',$imageResourceGroup) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<region>',$location) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<runOutputName>',$runOutputName) | Set-Content -Path $templateFilePath

((Get-Content -path $templateFilePath -Raw) -replace '<imageDefName>',$imageDefName) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<sharedImageGalName>',$sigGalleryName) | Set-Content -Path $templateFilePath
((Get-Content -path $templateFilePath -Raw) -replace '<region1>',$location) | Set-Content -Path $templateFilePath
#((Get-Content -path $templateFilePath -Raw) -replace '<region2>',$replRegion2) | Set-Content -Path $templateFilePath

((Get-Content -path $templateFilePath -Raw) -replace '<imgBuilderId>',$idenityNameResourceId) | Set-Content -Path $templateFilePath

((Get-Content -path $templateFilePath -Raw) -replace '<sigDefImgVersionId>',$sigDefImgVersionId) | Set-Content -Path $templateFilePath


############## Submit the template

New-AzResourceGroupDeployment -ResourceGroupName $imageResourceGroup -TemplateFile $templateFilePath -api-version "2019-05-01-preview" -imageTemplateName $imageTemplateName -svclocation $location

############# Build the Image

Invoke-AzResourceAction -ResourceName $imageTemplateName -ResourceGroupName $imageResourceGroup -ResourceType Microsoft.VirtualMachineImages/imageTemplates -ApiVersion "2019-05-01-preview" -Action Run -Force


############ Monitoring the Progress

### Step 1: Update context
$currentAzureContext = Get-AzContext

### Step 2: Get instance profile
$azureRmProfile = [Microsoft.Azure.Commands.Common.Authentication.Abstractions.AzureRmProfileProvider]::Instance.Profile
$profileClient = New-Object Microsoft.Azure.Commands.ResourceManager.Common.RMProfileClient($azureRmProfile)
    
Write-Verbose ("Tenant: {0}" -f  $currentAzureContext.Subscription.Name)
 
### Step 4: Get token  
$token = $profileClient.AcquireAccessToken($currentAzureContext.Tenant.TenantId)
$accessToken=$token.AccessToken


$managementEp = $currentAzureContext.Environment.ResourceManagerUrl


$urlBuildStatus = [System.String]::Format("{0}subscriptions/{1}/resourceGroups/$imageResourceGroup/providers/Microsoft.VirtualMachineImages/imageTemplates/{2}?api-version=2019-05-01-preview", $managementEp, $currentAzureContext.Subscription.Id,$imageTemplateName)

$buildStatusResult = Invoke-WebRequest -Method GET  -Uri $urlBuildStatus -UseBasicParsing -Headers  @{"Authorization"= ("Bearer " + $accessToken)} -ContentType application/json 
$buildJsonStatus =$buildStatusResult.Content
$buildJsonStatus
