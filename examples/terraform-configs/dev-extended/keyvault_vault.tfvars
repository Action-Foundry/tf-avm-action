# Key Vault Configuration
# This example shows how to deploy Azure Key Vault using AVM modules

keyvault_vault = {
  kv1 = {
    name                = "kv-myapp-dev-eus-001"
    location            = "eastus"
    resource_group_name = "rg-myapp-dev-eastus-001"
    tags = {
      cost_center = "engineering"
      owner       = "platform-team"
      environment = "dev"
      compliance  = "required"
    }
  }
}
