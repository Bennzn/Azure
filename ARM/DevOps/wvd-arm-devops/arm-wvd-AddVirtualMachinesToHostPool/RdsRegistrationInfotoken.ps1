# ARM RdsRegistrationInfotoken Used by arm parameter hostpoolToken
# Get RdsRegistrationInfotoken
# Import Modules for WVD

import-module az.desktopvirtualization
import-module az.network
import-module az.compute

$azureSubscriptionID = "157f3366-50f1-48c4-bae0-17de1998d98f"
$resourceGroupName = "RG-WVD-Test"
$existingWVDHostPoolName = "HP-WVD-Win10-20h2"

#$azureSubscriptionID = $args[0]
#$resourceGroupName = $args[1]
#$existingWVDHostPoolName = $args[2]


#Obtain RdsRegistrationInfotoken

$Registered = Get-AzWvdRegistrationInfo -SubscriptionId "$azureSubscriptionID" -ResourceGroupName "$resourceGroupName" -HostPoolName $existingWVDHostPoolName
if (-not(-Not $Registered.Token)){$registrationTokenValidFor = (NEW-TIMESPAN -Start (get-date) -End $Registered.ExpirationTime | select Days,Hours,Minutes,Seconds)}

$registrationTokenValidFor
if ((-Not $Registered.Token) -or ($Registered.ExpirationTime -le (get-date)))
{
    $Registered = New-AzWvdRegistrationInfo -SubscriptionId $azureSubscriptionID -ResourceGroupName $resourceGroupName -HostPoolName $existingWVDHostPoolName -ExpirationTime (Get-Date).AddHours(4) -ErrorAction SilentlyContinue
}
$RdsRegistrationInfotoken = $Registered.Token

# Write Host task.setvariable 
Write-Host "HostPool Token is $RdsRegistrationInfotoken"
Write-Host "$("##vso[task.setvariable variable=RdsRegistrationInfotoken]") $($RdsRegistrationInfotoken)"
