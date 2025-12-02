# Azure Verified Modules (AVM) Support

This document provides comprehensive guidance on using Azure Verified Modules (AVM) with the tf-avm-action to deploy Azure resources following Cloud Adoption Framework (CAF) standards and Azure best practices.

## Table of Contents

- [Overview](#overview)
- [What are Azure Verified Modules?](#what-are-azure-verified-modules)
- [Quick Start](#quick-start)
- [Directory Structure](#directory-structure)
- [Supported Resource Types](#supported-resource-types)
- [Usage Examples](#usage-examples)
- [Azure CAF Best Practices](#azure-caf-best-practices)
- [Advanced Configuration](#advanced-configuration)
- [Troubleshooting](#troubleshooting)

## Overview

The AVM mode in tf-avm-action enables streamlined deployment of Azure resources across multiple environments using:

- **Azure Verified Modules (AVM)**: Pre-validated, enterprise-ready Terraform modules from Microsoft
- **Environment-based deployment**: Support for dev, test, uat, staging, and prod environments
- **tfvars-driven configuration**: Simple, declarative configuration using `.tfvars` files
- **CAF compliance**: Built-in support for Azure Cloud Adoption Framework naming and tagging standards
- **DRY principles**: Reusable configurations across environments

## What are Azure Verified Modules?

Azure Verified Modules (AVM) are officially supported Terraform modules maintained by Microsoft and the community. They provide:

- ✅ **Best Practice Implementations**: Follow Azure's recommended patterns
- ✅ **Security Hardened**: Implement security defaults and best practices
- ✅ **Well Documented**: Comprehensive documentation and examples
- ✅ **Production Ready**: Tested and validated for enterprise use
- ✅ **Actively Maintained**: Regular updates and improvements

Learn more: [https://azure.github.io/Azure-Verified-Modules/](https://azure.github.io/Azure-Verified-Modules/)

## Quick Start

### 1. Create Directory Structure

```bash
# In your repository root
mkdir -p terraform/dev
mkdir -p terraform/prod
```

### 2. Create tfvars Files

**terraform/dev/resource_groups.tfvars**:
```hcl
resource_groups = {
  rg1 = {
    name     = "rg-myapp-dev-eastus-001"
    location = "eastus"
    tags = {
      cost_center = "engineering"
      owner       = "platform-team"
    }
  }
}
```

**terraform/dev/vnets.tfvars**:
```hcl
vnets = {
  vnet1 = {
    name                = "vnet-myapp-dev-eastus-001"
    location            = "eastus"
    resource_group_name = "rg-myapp-dev-eastus-001"
    address_space       = ["10.0.0.0/16"]
    subnets = {
      subnet1 = {
        name             = "snet-web-dev-001"
        address_prefixes = ["10.0.1.0/24"]
      }
      subnet2 = {
        name             = "snet-app-dev-001"
        address_prefixes = ["10.0.2.0/24"]
      }
    }
    tags = {
      cost_center = "engineering"
    }
  }
}
```

### 3. Configure Workflow

**.github/workflows/deploy-avm.yml**:
```yaml
name: Deploy Azure Resources with AVM

on:
  push:
    branches: [main]
  workflow_dispatch:
    inputs:
      environment:
        description: 'Environment to deploy'
        required: true
        type: choice
        options:
          - dev
          - prod

permissions:
  id-token: write
  contents: read

jobs:
  deploy:
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - name: Azure Login
        uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      
      - name: Deploy with AVM
        uses: Action-Foundry/tf-avm-action@v1
        with:
          # Enable AVM mode
          enable_avm_mode: 'true'
          
          # Specify environments (comma-separated for multiple)
          avm_environments: 'dev'
          
          # Resource types to deploy
          avm_resource_types: 'resource_groups,vnets,storage_accounts'
          
          # Default Azure location
          avm_location: 'eastus'
          
          # Terraform working directory
          terraform_working_dir: './terraform'
          
          # Azure authentication
          azure_client_id: ${{ secrets.AZURE_CLIENT_ID }}
          azure_tenant_id: ${{ secrets.AZURE_TENANT_ID }}
          azure_subscription_id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
          azure_use_oidc: 'true'
```

## Directory Structure

The recommended directory structure follows Azure CAF best practices:

```
repository/
├── .github/
│   └── workflows/
│       └── deploy-avm.yml          # Deployment workflow
├── terraform/                       # Terraform working directory
│   ├── dev/                        # Development environment
│   │   ├── resource_groups.tfvars  # Resource group definitions
│   │   ├── vnets.tfvars           # Virtual network definitions
│   │   └── storage_accounts.tfvars # Storage account definitions
│   ├── test/                       # Test environment
│   │   ├── resource_groups.tfvars
│   │   └── vnets.tfvars
│   ├── uat/                        # UAT environment
│   │   └── resource_groups.tfvars
│   ├── staging/                    # Staging environment
│   │   └── resource_groups.tfvars
│   └── prod/                       # Production environment
│       ├── resource_groups.tfvars
│       ├── vnets.tfvars
│       └── storage_accounts.tfvars
└── README.md
```

### Key Points:

- Each environment has its own folder under `terraform/`
- Environment folders contain `.tfvars` files for each resource type
- Standard environment names: `dev`, `test`, `uat`, `staging`, `prod`
- Only deploy resource types that have corresponding `.tfvars` files

## Supported Resource Types

**🎉 All 102 AVM Modules Supported!**

This action now supports **all 102 Azure Verified Modules** using a data-driven, DRY (Don't Repeat Yourself) architecture. You can use any of the modules listed below by specifying the resource type in the `avm_resource_types` input.

### Quick Reference: All Supported Modules

The following table lists all 102 supported AVM modules. Simply use the **Resource Type** value in your `avm_resource_types` input.

| # | Resource Type | Description | AVM Module |
|---|---------------|-------------|------------|
| 01 | `apimanagement_service` | API Management Service | [avm-res-apimanagement-service](https://registry.terraform.io/modules/Azure/avm-res-apimanagement-service/azurerm) |
| 02 | `app_containerapp` | Container App | [avm-res-app-containerapp](https://registry.terraform.io/modules/Azure/avm-res-app-containerapp/azurerm) |
| 03 | `app_job` | App Job | [avm-res-app-job](https://registry.terraform.io/modules/Azure/avm-res-app-job/azurerm) |
| 04 | `app_managedenvironment` | App Managed Environment | [avm-res-app-managedenvironment](https://registry.terraform.io/modules/Azure/avm-res-app-managedenvironment/azurerm) |
| 05 | `appconfiguration_configurationstore` | App Configuration Store | [avm-res-appconfiguration-configurationstore](https://registry.terraform.io/modules/Azure/avm-res-appconfiguration-configurationstore/azurerm) |
| 06 | `authorization_roleassignment` | Role Assignment | [avm-res-authorization-roleassignment](https://registry.terraform.io/modules/Azure/avm-res-authorization-roleassignment/azurerm) |
| 07 | `automation_automationaccount` | Automation Account | [avm-res-automation-automationaccount](https://registry.terraform.io/modules/Azure/avm-res-automation-automationaccount/azurerm) |
| 08 | `avs_privatecloud` | AVS Private Cloud | [avm-res-avs-privatecloud](https://registry.terraform.io/modules/Azure/avm-res-avs-privatecloud/azurerm) |
| 09 | `azurestackhci_cluster` | Azure Stack HCI Cluster | [avm-res-azurestackhci-cluster](https://registry.terraform.io/modules/Azure/avm-res-azurestackhci-cluster/azurerm) |
| 10 | `azurestackhci_logicalnetwork` | Azure Stack HCI Logical Network | [avm-res-azurestackhci-logicalnetwork](https://registry.terraform.io/modules/Azure/avm-res-azurestackhci-logicalnetwork/azurerm) |
| 11 | `azurestackhci_virtualmachineinstance` | Azure Stack HCI VM Instance | [avm-res-azurestackhci-virtualmachineinstance](https://registry.terraform.io/modules/Azure/avm-res-azurestackhci-virtualmachineinstance/azurerm) |
| 12 | `batch_batchaccount` | Batch Account | [avm-res-batch-batchaccount](https://registry.terraform.io/modules/Azure/avm-res-batch-batchaccount/azurerm) |
| 13 | `cache_redis` | Redis Cache | [avm-res-cache-redis](https://registry.terraform.io/modules/Azure/avm-res-cache-redis/azurerm) |
| 14 | `cdn_profile` | CDN Profile | [avm-res-cdn-profile](https://registry.terraform.io/modules/Azure/avm-res-cdn-profile/azurerm) |
| 15 | `certificateregistration_certificateorder` | Certificate Order | [avm-res-certificateregistration-certificateorder](https://registry.terraform.io/modules/Azure/avm-res-certificateregistration-certificateorder/azurerm) |
| 16 | `cognitiveservices_account` | Cognitive Services Account | [avm-res-cognitiveservices-account](https://registry.terraform.io/modules/Azure/avm-res-cognitiveservices-account/azurerm) |
| 17 | `communication_emailservice` | Communication Email Service | [avm-res-communication-emailservice](https://registry.terraform.io/modules/Azure/avm-res-communication-emailservice/azurerm) |
| 18 | `compute_capacityreservationgroup` | Capacity Reservation Group | [avm-res-compute-capacityreservationgroup](https://registry.terraform.io/modules/Azure/avm-res-compute-capacityreservationgroup/azurerm) |
| 19 | `compute_disk` | Compute Disk | [avm-res-compute-disk](https://registry.terraform.io/modules/Azure/avm-res-compute-disk/azurerm) |
| 20 | `compute_diskencryptionset` | Disk Encryption Set | [avm-res-compute-diskencryptionset](https://registry.terraform.io/modules/Azure/avm-res-compute-diskencryptionset/azurerm) |
| 21 | `compute_gallery` | Compute Gallery | [avm-res-compute-gallery](https://registry.terraform.io/modules/Azure/avm-res-compute-gallery/azurerm) |
| 22 | `compute_hostgroup` | Host Group | [avm-res-compute-hostgroup](https://registry.terraform.io/modules/Azure/avm-res-compute-hostgroup/azurerm) |
| 23 | `compute_proximityplacementgroup` | Proximity Placement Group | [avm-res-compute-proximityplacementgroup](https://registry.terraform.io/modules/Azure/avm-res-compute-proximityplacementgroup/azurerm) |
| 24 | `compute_sshpublickey` | SSH Public Key | [avm-res-compute-sshpublickey](https://registry.terraform.io/modules/Azure/avm-res-compute-sshpublickey/azurerm) |
| 25 | `compute_virtualmachine` | Virtual Machine | [avm-res-compute-virtualmachine](https://registry.terraform.io/modules/Azure/avm-res-compute-virtualmachine/azurerm) |
| 26 | `compute_virtualmachinescaleset` | VM Scale Set | [avm-res-compute-virtualmachinescaleset](https://registry.terraform.io/modules/Azure/avm-res-compute-virtualmachinescaleset/azurerm) |
| 27 | `containerinstance_containergroup` | Container Instance Group | [avm-res-containerinstance-containergroup](https://registry.terraform.io/modules/Azure/avm-res-containerinstance-containergroup/azurerm) |
| 28 | `containerregistry_registry` | Container Registry | [avm-res-containerregistry-registry](https://registry.terraform.io/modules/Azure/avm-res-containerregistry-registry/azurerm) |
| 29 | `containerservice_managedcluster` | AKS Managed Cluster | [avm-res-containerservice-managedcluster](https://registry.terraform.io/modules/Azure/avm-res-containerservice-managedcluster/azurerm) |
| 30 | `databricks_workspace` | Databricks Workspace | [avm-res-databricks-workspace](https://registry.terraform.io/modules/Azure/avm-res-databricks-workspace/azurerm) |
| 31 | `datafactory_factory` | Data Factory | [avm-res-datafactory-factory](https://registry.terraform.io/modules/Azure/avm-res-datafactory-factory/azurerm) |
| 32 | `dataprotection_backupvault` | Data Protection Backup Vault | [avm-res-dataprotection-backupvault](https://registry.terraform.io/modules/Azure/avm-res-dataprotection-backupvault/azurerm) |
| 33 | `dataprotection_resourceguard` | Data Protection Resource Guard | [avm-res-dataprotection-resourceguard](https://registry.terraform.io/modules/Azure/avm-res-dataprotection-resourceguard/azurerm) |
| 34 | `dbformysql_flexibleserver` | MySQL Flexible Server | [avm-res-dbformysql-flexibleserver](https://registry.terraform.io/modules/Azure/avm-res-dbformysql-flexibleserver/azurerm) |
| 35 | `dbforpostgresql_flexibleserver` | PostgreSQL Flexible Server | [avm-res-dbforpostgresql-flexibleserver](https://registry.terraform.io/modules/Azure/avm-res-dbforpostgresql-flexibleserver/azurerm) |
| 36 | `desktopvirtualization_applicationgroup` | AVD Application Group | [avm-res-desktopvirtualization-applicationgroup](https://registry.terraform.io/modules/Azure/avm-res-desktopvirtualization-applicationgroup/azurerm) |
| 37 | `desktopvirtualization_hostpool` | AVD Host Pool | [avm-res-desktopvirtualization-hostpool](https://registry.terraform.io/modules/Azure/avm-res-desktopvirtualization-hostpool/azurerm) |
| 38 | `desktopvirtualization_scalingplan` | AVD Scaling Plan | [avm-res-desktopvirtualization-scalingplan](https://registry.terraform.io/modules/Azure/avm-res-desktopvirtualization-scalingplan/azurerm) |
| 39 | `desktopvirtualization_workspace` | AVD Workspace | [avm-res-desktopvirtualization-workspace](https://registry.terraform.io/modules/Azure/avm-res-desktopvirtualization-workspace/azurerm) |
| 40 | `devcenter_devcenter` | Dev Center | [avm-res-devcenter-devcenter](https://registry.terraform.io/modules/Azure/avm-res-devcenter-devcenter/azurerm) |
| 41 | `devopsinfrastructure_pool` | DevOps Pool | [avm-res-devopsinfrastructure-pool](https://registry.terraform.io/modules/Azure/avm-res-devopsinfrastructure-pool/azurerm) |
| 42 | `documentdb_databaseaccount` | Cosmos DB Account | [avm-res-documentdb-databaseaccount](https://registry.terraform.io/modules/Azure/avm-res-documentdb-databaseaccount/azurerm) |
| 43 | `documentdb_mongocluster` | Cosmos DB MongoDB Cluster | [avm-res-documentdb-mongocluster](https://registry.terraform.io/modules/Azure/avm-res-documentdb-mongocluster/azurerm) |
| 44 | `edge_site` | Azure Arc Site | [avm-res-edge-site](https://registry.terraform.io/modules/Azure/avm-res-edge-site/azurerm) |
| 45 | `eventhub_namespace` | Event Hub Namespace | [avm-res-eventhub-namespace](https://registry.terraform.io/modules/Azure/avm-res-eventhub-namespace/azurerm) |
| 46 | `features_feature` | AFEC Feature | [avm-res-features-feature](https://registry.terraform.io/modules/Azure/avm-res-features-feature/azurerm) |
| 47 | `hybridcontainerservice_provisionedclusterinstance` | AKS Arc Cluster | [avm-res-hybridcontainerservice-provisionedclusterinstance](https://registry.terraform.io/modules/Azure/avm-res-hybridcontainerservice-provisionedclusterinstance/azurerm) |
| 48 | `insights_autoscalesetting` | Auto Scale Setting | [avm-res-insights-autoscalesetting](https://registry.terraform.io/modules/Azure/avm-res-insights-autoscalesetting/azurerm) |
| 49 | `insights_component` | Application Insights | [avm-res-insights-component](https://registry.terraform.io/modules/Azure/avm-res-insights-component/azurerm) |
| 50 | `insights_datacollectionendpoint` | Data Collection Endpoint | [avm-res-insights-datacollectionendpoint](https://registry.terraform.io/modules/Azure/avm-res-insights-datacollectionendpoint/azurerm) |
| 51 | `keyvault_vault` | Key Vault | [avm-res-keyvault-vault](https://registry.terraform.io/modules/Azure/avm-res-keyvault-vault/azurerm) |
| 52 | `kusto_cluster` | Kusto Cluster | [avm-res-kusto-cluster](https://registry.terraform.io/modules/Azure/avm-res-kusto-cluster/azurerm) |
| 53 | `logic_workflow` | Logic App Workflow | [avm-res-logic-workflow](https://registry.terraform.io/modules/Azure/avm-res-logic-workflow/azurerm) |
| 54 | `machinelearningservices_workspace` | ML Workspace | [avm-res-machinelearningservices-workspace](https://registry.terraform.io/modules/Azure/avm-res-machinelearningservices-workspace/azurerm) |
| 55 | `maintenance_maintenanceconfiguration` | Maintenance Configuration | [avm-res-maintenance-maintenanceconfiguration](https://registry.terraform.io/modules/Azure/avm-res-maintenance-maintenanceconfiguration/azurerm) |
| 56 | `managedidentity_userassignedidentity` | User Assigned Identity | [avm-res-managedidentity-userassignedidentity](https://registry.terraform.io/modules/Azure/avm-res-managedidentity-userassignedidentity/azurerm) |
| 57 | `management_servicegroup` | Management Service Group | [avm-res-management-servicegroup](https://registry.terraform.io/modules/Azure/avm-res-management-servicegroup/azurerm) |
| 58 | `netapp_netappaccount` | NetApp Account | [avm-res-netapp-netappaccount](https://registry.terraform.io/modules/Azure/avm-res-netapp-netappaccount/azurerm) |
| 59 | `network_applicationgateway` | Application Gateway | [avm-res-network-applicationgateway](https://registry.terraform.io/modules/Azure/avm-res-network-applicationgateway/azurerm) |
| 60 | `network_applicationgatewaywafpolicy` | App Gateway WAF Policy | [avm-res-network-applicationgatewaywafpolicy](https://registry.terraform.io/modules/Azure/avm-res-network-applicationgatewaywafpolicy/azurerm) |
| 61 | `network_applicationsecuritygroup` | Application Security Group | [avm-res-network-applicationsecuritygroup](https://registry.terraform.io/modules/Azure/avm-res-network-applicationsecuritygroup/azurerm) |
| 62 | `network_azurefirewall` | Azure Firewall | [avm-res-network-azurefirewall](https://registry.terraform.io/modules/Azure/avm-res-network-azurefirewall/azurerm) |
| 63 | `network_bastionhost` | Bastion Host | [avm-res-network-bastionhost](https://registry.terraform.io/modules/Azure/avm-res-network-bastionhost/azurerm) |
| 64 | `network_connection` | VNet Gateway Connection | [avm-res-network-connection](https://registry.terraform.io/modules/Azure/avm-res-network-connection/azurerm) |
| 65 | `network_ddosprotectionplan` | DDoS Protection Plan | [avm-res-network-ddosprotectionplan](https://registry.terraform.io/modules/Azure/avm-res-network-ddosprotectionplan/azurerm) |
| 66 | `network_dnsresolver` | DNS Resolver | [avm-res-network-dnsresolver](https://registry.terraform.io/modules/Azure/avm-res-network-dnsresolver/azurerm) |
| 67 | `network_dnszone` | Public DNS Zone | [avm-res-network-dnszone](https://registry.terraform.io/modules/Azure/avm-res-network-dnszone/azurerm) |
| 68 | `network_expressroutecircuit` | ExpressRoute Circuit | [avm-res-network-expressroutecircuit](https://registry.terraform.io/modules/Azure/avm-res-network-expressroutecircuit/azurerm) |
| 69 | `network_firewallpolicy` | Firewall Policy | [avm-res-network-firewallpolicy](https://registry.terraform.io/modules/Azure/avm-res-network-firewallpolicy/azurerm) |
| 70 | `network_frontdoorwafpolicy` | Front Door WAF Policy | [avm-res-network-frontdoorwafpolicy](https://registry.terraform.io/modules/Azure/avm-res-network-frontdoorwafpolicy/azurerm) |
| 71 | `network_ipgroup` | IP Group | [avm-res-network-ipgroup](https://registry.terraform.io/modules/Azure/avm-res-network-ipgroup/azurerm) |
| 72 | `network_loadbalancer` | Load Balancer | [avm-res-network-loadbalancer](https://registry.terraform.io/modules/Azure/avm-res-network-loadbalancer/azurerm) |
| 73 | `network_localnetworkgateway` | Local Network Gateway | [avm-res-network-localnetworkgateway](https://registry.terraform.io/modules/Azure/avm-res-network-localnetworkgateway/azurerm) |
| 74 | `network_natgateway` | NAT Gateway | [avm-res-network-natgateway](https://registry.terraform.io/modules/Azure/avm-res-network-natgateway/azurerm) |
| 75 | `network_networkinterface` | Network Interface | [avm-res-network-networkinterface](https://registry.terraform.io/modules/Azure/avm-res-network-networkinterface/azurerm) |
| 76 | `network_networkmanager` | Virtual Network Manager | [avm-res-network-networkmanager](https://registry.terraform.io/modules/Azure/avm-res-network-networkmanager/azurerm) |
| 77 | `network_networksecuritygroup` | Network Security Group | [avm-res-network-networksecuritygroup](https://registry.terraform.io/modules/Azure/avm-res-network-networksecuritygroup/azurerm) |
| 78 | `network_networkwatcher` | Network Watcher | [avm-res-network-networkwatcher](https://registry.terraform.io/modules/Azure/avm-res-network-networkwatcher/azurerm) |
| 79 | `network_privatednszone` | Private DNS Zone | [avm-res-network-privatednszone](https://registry.terraform.io/modules/Azure/avm-res-network-privatednszone/azurerm) |
| 80 | `network_privateendpoint` | Private Endpoint | [avm-res-network-privateendpoint](https://registry.terraform.io/modules/Azure/avm-res-network-privateendpoint/azurerm) |
| 81 | `network_publicipaddress` | Public IP Address | [avm-res-network-publicipaddress](https://registry.terraform.io/modules/Azure/avm-res-network-publicipaddress/azurerm) |
| 82 | `network_publicipprefix` | Public IP Prefix | [avm-res-network-publicipprefix](https://registry.terraform.io/modules/Azure/avm-res-network-publicipprefix/azurerm) |
| 83 | `network_routetable` | Route Table | [avm-res-network-routetable](https://registry.terraform.io/modules/Azure/avm-res-network-routetable/azurerm) |
| 84 | `network_virtualnetwork` (or `vnets`) | Virtual Network | [avm-res-network-virtualnetwork](https://registry.terraform.io/modules/Azure/avm-res-network-virtualnetwork/azurerm) |
| 85 | `operationalinsights_workspace` | Log Analytics Workspace | [avm-res-operationalinsights-workspace](https://registry.terraform.io/modules/Azure/avm-res-operationalinsights-workspace/azurerm) |
| 86 | `oracledatabase_cloudexadatainfrastructure` | Oracle Exadata Infrastructure | [avm-res-oracledatabase-cloudexadatainfrastructure](https://registry.terraform.io/modules/Azure/avm-res-oracledatabase-cloudexadatainfrastructure/azurerm) |
| 87 | `oracledatabase_cloudvmcluster` | Oracle VM Cluster | [avm-res-oracledatabase-cloudvmcluster](https://registry.terraform.io/modules/Azure/avm-res-oracledatabase-cloudvmcluster/azurerm) |
| 88 | `portal_dashboard` | Portal Dashboard | [avm-res-portal-dashboard](https://registry.terraform.io/modules/Azure/avm-res-portal-dashboard/azurerm) |
| 89 | `recoveryservices_vault` | Recovery Services Vault | [avm-res-recoveryservices-vault](https://registry.terraform.io/modules/Azure/avm-res-recoveryservices-vault/azurerm) |
| 90 | `redhatopenshift_openshiftcluster` | OpenShift Cluster | [avm-res-redhatopenshift-openshiftcluster](https://registry.terraform.io/modules/Azure/avm-res-redhatopenshift-openshiftcluster/azurerm) |
| 91 | `resourcegraph_query` | Resource Graph Query | [avm-res-resourcegraph-query](https://registry.terraform.io/modules/Azure/avm-res-resourcegraph-query/azurerm) |
| 92 | `resources_resourcegroup` (or `resource_groups`) | Resource Group | [avm-res-resources-resourcegroup](https://registry.terraform.io/modules/Azure/avm-res-resources-resourcegroup/azurerm) |
| 93 | `search_searchservice` | Search Service | [avm-res-search-searchservice](https://registry.terraform.io/modules/Azure/avm-res-search-searchservice/azurerm) |
| 94 | `servicebus_namespace` | Service Bus Namespace | [avm-res-servicebus-namespace](https://registry.terraform.io/modules/Azure/avm-res-servicebus-namespace/azurerm) |
| 95 | `sql_managedinstance` | SQL Managed Instance | [avm-res-sql-managedinstance](https://registry.terraform.io/modules/Azure/avm-res-sql-managedinstance/azurerm) |
| 96 | `sql_server` | SQL Server | [avm-res-sql-server](https://registry.terraform.io/modules/Azure/avm-res-sql-server/azurerm) |
| 97 | `storage_storageaccount` (or `storage_accounts`) | Storage Account | [avm-res-storage-storageaccount](https://registry.terraform.io/modules/Azure/avm-res-storage-storageaccount/azurerm) |
| 98 | `web_connection` | API Connection | [avm-res-web-connection](https://registry.terraform.io/modules/Azure/avm-res-web-connection/azurerm) |
| 99 | `web_hostingenvironment` | App Service Environment | [avm-res-web-hostingenvironment](https://registry.terraform.io/modules/Azure/avm-res-web-hostingenvironment/azurerm) |
| 100 | `web_serverfarm` | App Service Plan | [avm-res-web-serverfarm](https://registry.terraform.io/modules/Azure/avm-res-web-serverfarm/azurerm) |
| 101 | `web_site` | Web/Function App | [avm-res-web-site](https://registry.terraform.io/modules/Azure/avm-res-web-site/azurerm) |
| 102 | `web_staticsite` | Static Web App | [avm-res-web-staticsite](https://registry.terraform.io/modules/Azure/avm-res-web-staticsite/azurerm) |

### Usage Example: Multiple Module Types

```yaml
- name: Deploy Multiple Resource Types
  uses: Action-Foundry/tf-avm-action@v1
  with:
    enable_avm_mode: 'true'
    avm_environments: 'dev'
    # Specify any combination of the 102 supported modules
    avm_resource_types: 'resource_groups,keyvault_vault,sql_server,containerservice_managedcluster'
    terraform_working_dir: './terraform'
    azure_use_oidc: 'true'
```

### Generic tfvars Format

For most modules (except those with special requirements like VNets with subnets), use this generic format:

**terraform/dev/`<resource_type>`.tfvars**:
```hcl
<resource_type> = {
  resource1 = {
    name                = "<resource-name>"
    location            = "eastus"  # Optional, defaults to avm_location
    resource_group_name = "<resource-group-name>"
    tags = {
      environment = "dev"
      owner       = "team-name"
    }
    # Additional module-specific properties can be added here
    # Refer to the specific AVM module documentation for available options
  }
}
```

For detailed examples and module-specific configurations, refer to the sections below and the individual AVM module documentation.

---

## Detailed Module Examples

### Resource Groups

**Module**: `Azure/avm-res-resources-resourcegroup/azurerm`

**tfvars Format** (`resource_groups.tfvars`):
```hcl
resource_groups = {
  # Key is a logical identifier (used internally)
  rg1 = {
    name     = "rg-myapp-dev-eastus-001"  # Actual Azure resource name
    location = "eastus"                    # Azure region
    tags = {
      cost_center = "engineering"
      owner       = "platform-team"
    }
  }
  
  rg2 = {
    name     = "rg-data-dev-eastus-001"
    location = "eastus"
    tags = {
      cost_center = "data"
    }
  }
}
```

**Naming Convention** (CAF-compliant):
```
rg-<app-or-service>-<environment>-<region>-<instance>
Example: rg-myapp-dev-eastus-001
```

### Virtual Networks (VNets)

**Module**: `Azure/avm-res-network-virtualnetwork/azurerm`

**tfvars Format** (`vnets.tfvars`):
```hcl
vnets = {
  vnet1 = {
    name                = "vnet-myapp-dev-eastus-001"
    location            = "eastus"
    resource_group_name = "rg-myapp-dev-eastus-001"  # Must exist
    address_space       = ["10.0.0.0/16"]
    
    subnets = {
      web = {
        name             = "snet-web-dev-001"
        address_prefixes = ["10.0.1.0/24"]
      }
      app = {
        name             = "snet-app-dev-001"
        address_prefixes = ["10.0.2.0/24"]
      }
      data = {
        name             = "snet-data-dev-001"
        address_prefixes = ["10.0.3.0/24"]
      }
    }
    
    tags = {
      cost_center = "engineering"
    }
  }
}
```

**Naming Convention** (CAF-compliant):
```
VNet:   vnet-<app-or-service>-<environment>-<region>-<instance>
Subnet: snet-<purpose>-<environment>-<instance>

Examples:
  vnet-myapp-dev-eastus-001
  snet-web-dev-001
```

### Storage Accounts

**Module**: `Azure/avm-res-storage-storageaccount/azurerm`

**tfvars Format** (`storage_accounts.tfvars`):
```hcl
storage_accounts = {
  sa1 = {
    name                     = "stmyappdeveastus001"  # Must be globally unique, 3-24 chars, lowercase, no hyphens
    location                 = "eastus"
    resource_group_name      = "rg-myapp-dev-eastus-001"
    account_tier             = "Standard"              # Standard or Premium
    account_replication_type = "LRS"                   # LRS, GRS, RAGRS, ZRS
    account_kind             = "StorageV2"             # StorageV2 (recommended), BlobStorage, FileStorage
    tags = {
      cost_center = "engineering"
      data_classification = "internal"
    }
  }
}
```

**Naming Convention** (CAF-compliant):
```
st<app-or-service><environment><region><instance>
Example: stmyappdeveastus001

Note: Storage account names must be:
- Globally unique across all of Azure
- 3-24 characters
- Lowercase letters and numbers only
- No hyphens or special characters
```

## Usage Examples

### Single Environment Deployment

Deploy only the development environment:

```yaml
- name: Deploy Dev Environment
  uses: Action-Foundry/tf-avm-action@v1
  with:
    enable_avm_mode: 'true'
    avm_environments: 'dev'
    avm_resource_types: 'resource_groups,vnets,storage_accounts'
    terraform_working_dir: './terraform'
    azure_use_oidc: 'true'
```

### Multi-Environment Deployment

Deploy multiple environments in sequence:

```yaml
- name: Deploy Multiple Environments
  uses: Action-Foundry/tf-avm-action@v1
  with:
    enable_avm_mode: 'true'
    avm_environments: 'dev,test,prod'  # Comma-separated
    avm_resource_types: 'resource_groups,vnets'
    terraform_working_dir: './terraform'
    azure_use_oidc: 'true'
```

### Selective Resource Deployment

Deploy only specific resource types:

```yaml
- name: Deploy Only Resource Groups
  uses: Action-Foundry/tf-avm-action@v1
  with:
    enable_avm_mode: 'true'
    avm_environments: 'dev'
    avm_resource_types: 'resource_groups'  # Only RGs
    terraform_working_dir: './terraform'
```

### Custom Azure Location

Override the default location:

```yaml
- name: Deploy to West Europe
  uses: Action-Foundry/tf-avm-action@v1
  with:
    enable_avm_mode: 'true'
    avm_environments: 'prod'
    avm_location: 'westeurope'  # Default location
    terraform_working_dir: './terraform'
```

### With Backend Configuration

Use Azure Storage for state:

```yaml
- name: Deploy with Remote State
  uses: Action-Foundry/tf-avm-action@v1
  with:
    enable_avm_mode: 'true'
    avm_environments: 'prod'
    terraform_working_dir: './terraform'
    terraform_backend_config: |
      storage_account_name=mytfstate
      container_name=tfstate
      resource_group_name=rg-tfstate-prod
    azure_use_oidc: 'true'
```

### Matrix Strategy for Multiple Environments

Deploy environments in parallel:

```yaml
jobs:
  deploy:
    strategy:
      matrix:
        environment: [dev, test, prod]
    runs-on: ubuntu-latest
    steps:
      - uses: actions/checkout@v4
      
      - uses: azure/login@v2
        with:
          client-id: ${{ secrets.AZURE_CLIENT_ID }}
          tenant-id: ${{ secrets.AZURE_TENANT_ID }}
          subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
      
      - name: Deploy ${{ matrix.environment }}
        uses: Action-Foundry/tf-avm-action@v1
        with:
          enable_avm_mode: 'true'
          avm_environments: ${{ matrix.environment }}
          terraform_working_dir: './terraform'
          azure_use_oidc: 'true'
```

## Azure CAF Best Practices

### Naming Conventions

The action supports and encourages Azure Cloud Adoption Framework naming conventions:

| Resource Type | Format | Example |
|--------------|--------|---------|
| Resource Group | `rg-<workload>-<env>-<region>-<###>` | `rg-myapp-dev-eastus-001` |
| Virtual Network | `vnet-<workload>-<env>-<region>-<###>` | `vnet-myapp-dev-eastus-001` |
| Subnet | `snet-<purpose>-<env>-<###>` | `snet-web-dev-001` |
| Storage Account | `st<workload><env><region><###>` | `stmyappdeveastus001` |

**References**:
- [Azure Naming Convention Best Practices](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- [Resource Naming Examples](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-naming)

### Tagging Strategy

Standard tags are automatically applied by the action:

```hcl
tags = {
  environment = "<env>"           # Automatically set (dev, test, prod, etc.)
  managed_by  = "terraform"       # Automatically set
  module      = "<avm-module>"    # Automatically set
}
```

Recommended additional tags to include in your tfvars:

```hcl
tags = {
  cost_center         = "engineering"
  owner               = "platform-team"
  project             = "myapp"
  data_classification = "internal"  # For storage accounts
  backup              = "required"  # For production resources
  dr_tier             = "mission-critical"  # For critical resources
}
```

**Reference**: [Azure Tagging Strategy](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/resource-tagging)

### Environment Strategy

Recommended environment naming and purpose:

| Environment | Purpose | Typical Configuration |
|-------------|---------|---------------------|
| `dev` | Development | Lower SKUs, minimal redundancy |
| `test` | Testing/QA | Similar to dev, isolated |
| `uat` | User Acceptance Testing | Production-like config |
| `staging` | Pre-production | Identical to production |
| `prod` | Production | High availability, redundancy |

### Security Best Practices

1. **Use OIDC Authentication** (no secrets in workflows):
   ```yaml
   permissions:
     id-token: write
   
   - uses: azure/login@v2
     with:
       client-id: ${{ secrets.AZURE_CLIENT_ID }}
       tenant-id: ${{ secrets.AZURE_TENANT_ID }}
       subscription-id: ${{ secrets.AZURE_SUBSCRIPTION_ID }}
   ```

2. **Store State Remotely**:
   ```yaml
   terraform_backend_config: |
     storage_account_name=mytfstate
     container_name=tfstate
   ```

3. **Use Environment Protection Rules**:
   - Require approvals for production deployments
   - Limit who can deploy to production
   - Use GitHub Environments feature

4. **Review Plans Before Apply**:
   - In CI/CD, review Terraform plans
   - Use PR workflows for plan reviews

## Advanced Configuration

### Custom Module Versions

By default, the action uses the latest compatible version (`~> 0.1`) of each AVM module. This ensures you get updates while maintaining compatibility.

The module versions are defined in the generated Terraform configuration and follow semantic versioning:
- `~> 0.1`: Allows patch and minor updates (0.1.x)
- `~> 1.0`: Allows patch and minor updates (1.x.x)

### Extending to New Resource Types

To add support for additional AVM modules, you'll need to:

1. Add the resource type to `avm_resource_types` input
2. Create corresponding tfvars files in your environment directories
3. The action currently supports: `resource_groups`, `vnets`, `storage_accounts`

For other resource types, use the standard Terraform workflow mode instead of AVM mode.

### Combining with Standard Terraform

You cannot use both `enable_avm_mode` and `terraform_command` in the same workflow step. Choose one approach:

**Option 1: AVM Mode Only**
```yaml
- uses: Action-Foundry/tf-avm-action@v1
  with:
    enable_avm_mode: 'true'
    avm_environments: 'dev'
```

**Option 2: Standard Terraform Only**
```yaml
- uses: Action-Foundry/tf-avm-action@v1
  with:
    terraform_command: 'full'
    terraform_working_dir: './terraform'
```

**Option 3: Separate Steps**
```yaml
- name: Deploy AVM Resources
  uses: Action-Foundry/tf-avm-action@v1
  with:
    enable_avm_mode: 'true'
    avm_environments: 'dev'

- name: Deploy Custom Resources
  uses: Action-Foundry/tf-avm-action@v1
  with:
    terraform_command: 'full'
    terraform_working_dir: './terraform-custom'
```

## Troubleshooting

### Common Issues

#### Environment Directory Not Found

**Error**: `Environment directory not found: terraform/dev`

**Solution**: Create the directory and add at least one `.tfvars` file:
```bash
mkdir -p terraform/dev
# Then create resource_groups.tfvars or other tfvars files
```

#### No tfvars Files Found

**Warning**: `Skipping resource_groups: tfvars file not found`

**Solution**: The action skips resource types that don't have corresponding tfvars files. This is normal if you only want to deploy certain resource types.

#### Module Download Failures

**Error**: Module download or initialization failures

**Solution**: 
1. Ensure the runner has internet access to `registry.terraform.io`
2. Check that you're using a supported Terraform version (>= 1.5.0)
3. Verify no corporate proxy is blocking module downloads

#### Resource Already Exists

**Error**: Resource already exists in Azure

**Solution**:
1. Import existing resources: Use `terraform import` before running the action
2. Use unique names: Ensure resource names are unique, especially for storage accounts
3. Check backend state: Verify you're using the correct state file

#### Authentication Failures

**Error**: Azure authentication failed

**Solution**:
1. Verify service principal credentials are correct
2. Check that the service principal has appropriate permissions
3. Ensure OIDC federation is configured correctly if using OIDC
4. Run `azure/login` action before this action

### Getting Help

If you encounter issues:

1. Check the [Examples](examples/) directory for working configurations
2. Review the [README](README.md) for general action usage
3. Enable debug logging: Set `ACTIONS_STEP_DEBUG=true` repository secret
4. Open an [issue](https://github.com/Action-Foundry/tf-avm-action/issues) with:
   - Workflow configuration
   - Error messages
   - Tfvars file structure (sanitized)

## Additional Resources

- [Azure Verified Modules Registry](https://azure.github.io/Azure-Verified-Modules/)
- [Terraform Registry - AVM Modules](https://registry.terraform.io/search/modules?namespace=Azure&q=avm)
- [Azure Cloud Adoption Framework](https://docs.microsoft.com/azure/cloud-adoption-framework/)
- [Azure Naming Best Practices](https://docs.microsoft.com/azure/cloud-adoption-framework/ready/azure-best-practices/naming-and-tagging)
- [Action Repository](https://github.com/Action-Foundry/tf-avm-action)

---

*For questions or feedback, please open a discussion or issue in the [repository](https://github.com/Action-Foundry/tf-avm-action).*
