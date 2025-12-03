# Event Hub Namespace Configuration
# This example shows how to deploy Azure Event Hub using AVM modules

eventhub_namespace = {
  eh1 = {
    name                = "evhns-myapp-dev-eastus-001"
    location            = "eastus"
    resource_group_name = "rg-myapp-dev-eastus-001"
    tags = {
      cost_center = "engineering"
      owner       = "data-team"
      environment = "dev"
      data_class  = "internal"
    }
  }
}
