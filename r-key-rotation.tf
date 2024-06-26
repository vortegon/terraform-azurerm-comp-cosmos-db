resource "azurerm_key_vault_secret" "cosmosdb_secret_key" {
  name         = "cosmosdb-key-${var.resource_group_name}-${azurerm_cosmosdb_account.db.name}"
  value        = azurerm_cosmosdb_account.db.primary_key
  key_vault_id = var.keyvault_id

  tags = {
    ProviderAddress = azurerm_cosmosdb_account.db.id
    CredentialId  = "Primary"
    ValidityPeriodDays = var.key_validity_period_days
  }
}

resource "azurerm_user_assigned_identity" "cosmosdb_secret_key_manged_identity" {
  location            = var.location
  name                = "umi-${azurerm_cosmosdb_account.db.name}-secret-key"
  resource_group_name = var.resource_group_name
}

resource "azurerm_role_assignment" "secret_permissions" {
  scope                = azurerm_key_vault_secret.cosmosdb_secret_key.resource_versionless_id
  role_definition_name = "Key Vault Secrets User"
  principal_id         = azurerm_user_assigned_identity.cosmosdb_secret_key_manged_identity.principal_id
}
