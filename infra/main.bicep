targetScope = 'subscription'

// The main bicep module to provision Azure resources.
// For a more complete walkthrough to understand how this file works with azd,
// see https://learn.microsoft.com/en-us/azure/developer/azure-developer-cli/make-azd-compatible?pivots=azd-create

@minLength(1)
@maxLength(64)
@description('Name of the the environment.')
param environmentName string

@minLength(1)
@description('Primary location for all resources')
param location string

@description('Id of the user or app to assign application roles')
param principalId string = ''

@description('Resource name for storage account')
param storageAccountName string

@description('Resource name for container app environment')
param containerAppsEnvName string

@description('Resource name for container app')
param containerAppsAppName string

@description('Resource name for container registry')
param containerRegistryName string 

@description('Resource name for service app')
param serviceName string = 'aca'
var abbrs = loadJsonContent('./abbreviations.json')

var tags = {
  'azd-env-name': environmentName
}

// Organize resources in a resource group
resource rg 'Microsoft.Resources/resourceGroups@2021-04-01' = {
  name: 'abbrs.resourcesResourceGroups'
  location: location
  tags: tags
}

// Create a user assigned identity
module identity './app/user-assigned-identity.bicep' = {
  name: 'identity'
  scope: rg
  params: {
    name: 'hello-azd-identity'
  }
}

// Create a storage account
module storage './core/storage/storage-account.bicep' = {
  name: 'storage'
  scope: rg
  params: {
    name: storageAccountName
    location: location
    tags: tags
    allowSharedKeyAccess: false
    containers: [
      {
        name: 'attachments'
      }
    ]
    tables: [
      {
        name: 'tickets'
      }
    ]
  }
}

// Assign storage blob data contributor to the user for local runs
module userAssignStorage './core/security/role.bicep' = {
  name: 'assignStorage'
  scope: rg
  params: {
    principalId: principalId
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe' // built-in role definition id for storage blob data contributor
    principalType: 'ServicePrincipal'
  }
}

// Assign storage blob data contributor to the identity
module identityAssignStorage './core/security/role.bicep' = {
  name: 'identityAssignStorage'
  scope: rg
  params: {
    principalId: identity.outputs.principalId
    roleDefinitionId: 'ba92f5b4-2d11-453d-a403-e96b0029c9fe'
    principalType: 'ServicePrincipal'
  }
}

// Assign storage table data contributor to the user for local runs
module userAssignTable './core/security/role.bicep' = {
  name: 'assignTable'
  scope: rg
  params: {
    principalId: principalId
    roleDefinitionId: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3' // built-in role definition id for storage table data contributor
    principalType: 'ServicePrincipal'
  }
}

// Assign storage table data contributor to the identity
module identityAssignTable './core/security/role.bicep' = {
  name: 'identityAssignTable'
  scope: rg
  params: {
    principalId: identity.outputs.principalId
    roleDefinitionId: '0a9a7e1f-b9d0-4cc4-a60d-0319b160aaa3'
    principalType: 'ServicePrincipal'
  }
}

// Container apps env and registry
module containerAppsEnv './core/host/container-apps.bicep' = {
  name: 'container-apps'
  scope: rg
  params: {
    name: 'app'
    containerAppsEnvironmentName: containerAppsEnvName
    containerRegistryName: containerRegistryName
    location: location
  }
}

// Container app
module web 'app/app.bicep' = {
  name: containerAppsAppName
  scope: rg
  params: {
    appName: containerAppsAppName
    storageAccountBlobEndpoint: storage.outputs.blobEndpoint
    storageAccountTableEndpoint: storage.outputs.tableEndpoint
    containerAppsEnvironmentName: containerAppsEnv.outputs.environmentName
    containerRegistryName: containerAppsEnv.outputs.registryName
    userAssignedManagedIdentity: {
      resourceId: identity.outputs.resourceId
      clientId: identity.outputs.clientId
    }
    location: location
    tags: tags
    serviceName: serviceName
    exists: false
    identityName: identity.outputs.name
  }
}


output AZURE_LOCATION string = location
output AZURE_TENANT_ID string = tenant().tenantId
// Container outputs
output AZURE_CONTAINER_REGISTRY_ENDPOINT string = containerAppsEnv.outputs.registryLoginServer
output AZURE_CONTAINER_REGISTRY_NAME string = containerAppsEnv.outputs.registryName

// // Application outputs
// output AZURE_CONTAINER_APP_ENDPOINT string = web.outputs.endpoint
// output AZURE_CONTAINER_ENVIRONMENT_NAME string = web.outputs.envName

output AZURE_USER_ASSIGNED_IDENTITY_NAME string = identity.outputs.name
