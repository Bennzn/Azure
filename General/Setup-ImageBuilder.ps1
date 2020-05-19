# Image Builder first Deplpy

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
$imageName="imageBuilderCustomW2k19"

# image template name
$imageTemplateName="imageBuilderCustomTemplateW2k19"

# distribution properties object name (runOutput), i.e. this gives you the properties of the managed image on completion
$runOutputName="ImageBuilderTest"

# create resource group
#New-AzResourceGroup -Name $imageResourceGroup -Location $location

#################################################################


# setup role def names, these need to be unique
#$timeInt=$(get-date -UFormat "%s")
#$imageRoleDefName="Azure Image Builder Image Def"+$timeInt
$imageRoleDefName="Azure Image Builder Image Def Dev"
#$idenityName="ImageBuilderIdentity"+$timeInt
$idenityName="ImageBuilderIdentityDev"

## Add AZ PS module to support AzUserAssignedIdentity
Install-Module -Name Az.ManagedServiceIdentity

# create identity
New-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $idenityName

$idenityNameResourceId=$(Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $idenityName).Id
$idenityNamePrincipalId=$(Get-AzUserAssignedIdentity -ResourceGroupName $imageResourceGroup -Name $idenityName).PrincipalId

########################################################################



$aibRoleImageCreationUrl="https://raw.githubusercontent.com/danielsollondon/azvmimagebuilder/master/solutions/12_Creating_AIB_Security_Roles/aibRoleImageCreation.json"
$aibRoleImageCreationPath = "aibRoleImageCreation.json"

# download config
Invoke-WebRequest -Uri $aibRoleImageCreationUrl -OutFile $aibRoleImageCreationPath -UseBasicParsing

((Get-Content -path $aibRoleImageCreationPath -Raw) -replace '<subscriptionID>',$subscriptionID) | Set-Content -Path $aibRoleImageCreationPath
((Get-Content -path $aibRoleImageCreationPath -Raw) -replace '<rgName>', $imageResourceGroup) | Set-Content -Path $aibRoleImageCreationPath
((Get-Content -path $aibRoleImageCreationPath -Raw) -replace 'Azure Image Builder Service Image Creation Role', $imageRoleDefName) | Set-Content -Path $aibRoleImageCreationPath

# create role definition
New-AzRoleDefinition -InputFile  ./aibRoleImageCreation.json

# grant role definition to image builder service principal
New-AzRoleAssignment -ObjectId $idenityNamePrincipalId -RoleDefinitionName $imageRoleDefName -Scope "/subscriptions/$subscriptionID/resourceGroups/$imageResourceGroup"

##################################################################################

$sigGalleryName= "imagebuilder_sig"
$imageDefName ="AB-CustomW2k19"

# additional replication region
$replRegion2="westeurop"

# create gallery
New-AzGallery -GalleryName $sigGalleryName -ResourceGroupName $imageResourceGroup  -Location $location

# create gallery definition
New-AzGalleryImageDefinition -GalleryName $sigGalleryName -ResourceGroupName $imageResourceGroup -Location $location -Name $imageDefName -OsState generalized -OsType Windows -Publisher 'ACSResearch' -Offer 'Windows' -Sku 'Win2019'

