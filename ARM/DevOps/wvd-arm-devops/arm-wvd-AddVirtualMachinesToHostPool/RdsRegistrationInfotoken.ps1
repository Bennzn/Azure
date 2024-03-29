# ARM RdsRegistrationInfotoken Used by arm parameter hostpoolToken
# Get RdsRegistrationInfotoken
# Import Modules for WVD

import-module az.desktopvirtualization
import-module az.network
import-module az.compute

#$azureSubscriptionID = "0"
#$resourceGroupName = "0"
#$existingWVDHostPoolName = "0"

#$azureSubscriptionID = $args[0]
$resourceGroupName = $args[0]
$existingWVDHostPoolName = $args[1]


#Obtain RdsRegistrationInfotoken

$Registered = Get-AzWvdRegistrationInfo -ResourceGroupName "$resourceGroupName" -HostPoolName $existingWVDHostPoolName
if (-not(-Not $Registered.Token)){$registrationTokenValidFor = (NEW-TIMESPAN -Start (get-date) -End $Registered.ExpirationTime | select Days,Hours,Minutes,Seconds)}

$registrationTokenValidFor
if ((-Not $Registered.Token) -or ($Registered.ExpirationTime -le (get-date)))
{
    $Registered = New-AzWvdRegistrationInfo -SubscriptionId $azureSubscriptionID -ResourceGroupName $resourceGroupName -HostPoolName $existingWVDHostPoolName -ExpirationTime (Get-Date).AddHours(4) -ErrorAction SilentlyContinue
}
$RdsRegistrationInfotoken = $Registered.Token

# Write Host task.setvariable 
#Write-Host "##vso[task.setvariable variable=RdsRegistrationInfotoken;]$RdsRegistrationInfotoken"
Write-Host "$("##vso[task.setvariable variable=RdsRegistrationInfotoken;]")$($RdsRegistrationInfotoken)"
