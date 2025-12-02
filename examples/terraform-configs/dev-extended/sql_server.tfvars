# Azure SQL Server Configuration
# This example shows how to deploy Azure SQL Server using AVM modules

sql_server = {
  sql1 = {
    name                = "sql-myapp-dev-eastus-001"
    location            = "eastus"
    resource_group_name = "rg-myapp-dev-eastus-001"
    tags = {
      cost_center = "engineering"
      owner       = "data-team"
      environment = "dev"
      backup      = "required"
    }
  }
}
