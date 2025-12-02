# AKS Managed Cluster Configuration
# This example shows how to deploy Azure Kubernetes Service using AVM modules

containerservice_managedcluster = {
  aks1 = {
    name                = "aks-myapp-dev-eastus-001"
    location            = "eastus"
    resource_group_name = "rg-myapp-dev-eastus-001"
    tags = {
      cost_center = "engineering"
      owner       = "platform-team"
      environment = "dev"
      criticality = "high"
    }
  }
}
