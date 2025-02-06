param keyVaultName string = 'licenseKeyVault-${uniqueString(resourceGroup().id)}'
param privateEndpointName string = 'licenseKeyVault'
param accessPolicies array = []  // Default to empty array if not passed
param location string = 'northeurope'  // Explicitly set location to North Europe
param tenantId string = '300f59df-78e6-436f-9b27-b64973e34f7d'
param objectId string = '62bf02de-f6ab-4cb1-aa15-eb816909bcf8'  // Your application/service principal Object ID

resource keyVault 'Microsoft.KeyVault/vaults@2021-06-01-preview' = {
  name: keyVaultName
  location: location
  properties: {
    sku: {
      family: 'A'
      name: 'standard'
    }
    tenantId: tenantId
    accessPolicies: arrayUnroll(accessPolicies) ++ [
      {
        tenantId: tenantId
        objectId: objectId
        permissions: {
          secrets: [
            'get'
            'list'
            'set'
          ]
        }
      }
    ]
  }
}

resource privateEndpoint 'Microsoft.Network/privateEndpoints@2021-03-01' = {
  name: privateEndpointName
  location: location
  properties: {
    subnet: {
      id: resourceId('Microsoft.Network/virtualNetworks/subnets', 'Test', 'Test')  // Ensure this subnet exists
    }
    privateLinkServiceConnections: [
      {
        name: 'keyvault-connection'
        properties: {
          privateLinkServiceConnectionState: {
            status: 'Approved'
            description: 'Auto-approved'
          }
          privateLinkServiceId: keyVault.id  // Correct property for the private link service
          groupIds: ['vault']
        }
      }
    ]
  }
}
