param location string = 'northeurope'
param resourceGroupName string
param vnetName string
param subnetName string
param keyVaultName string
param privateEndpointName string
param secretName string


resource keyVault 'Microsoft.KeyVault/vaults@2023-02-01' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: subscription().tenantId
    enablePurgeProtection: true
    enableSoftDelete: true
  }
}

resource vnet 'Microsoft.Network/virtualNetworks@2023-02-01' existing = {
  name: vnetName
  scope: resourceGroup(resourceGroupName)
}

resource subnet 'Microsoft.Network/virtualNetworks/subnets@2023-02-01' existing = {
  name: subnetName
  parent: vnet
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2023-02-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: subnet.id
    }
    privateLinkServiceConnections: [
      {
        name: '${keyVaultName}-connection'
        properties: {
          privateLinkServiceId: keyVault.id
          groupIds: ['vault']
        }
      }
    ]
  }
}

output keyVaultUri string = keyVault.properties.vaultUri
