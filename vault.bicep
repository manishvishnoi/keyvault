param keyVaultName string = 'licenseKeyVault-${uniqueString(resourceGroup().id)'
param privateEndpointName string = 'licenseKeyVault'
param accessPolicies array = []  // Default to empty array if not passed
param location string = 'northeurope'  // Explicitly set location to North Europe

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {  // Use 2021-06-01-preview API version
  name: keyVaultName
  location: location  // Set location to North Europe
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: '9436480f-c708-4e0f-aba3-3d5af128e84a'  // Replace with actual tenant ID
    accessPolicies: accessPolicies
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: privateEndpointName
  location: location  // Set location to North Europe
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'Test', 'Test')  // Correct use of resourceId for subnet
    }
    privateLinkServiceConnections: [
      {
        name: 'keyvault-connection'
        properties: {
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-approved'
          }
          privateLinkServiceConnection: {
            privateLinkServiceId: keyVault.id
            groupIds: ['vault']
          }
        }
      }
    ]
  }
}
