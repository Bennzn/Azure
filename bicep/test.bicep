resource stg 'Microsoft.Storage/storageAccounts@2020-08-01-preview' = {

 name: 'myteststorage' 
 location: 'westeurope'
 kind: 'StorageV2'
 sku:{
   name: 'Standard_LRS'
 }
}