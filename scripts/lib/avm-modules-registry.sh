#!/bin/bash
# avm-modules-registry.sh - Registry of all supported AVM modules
# This file contains the configuration for all 102 AVM modules
# Each module is defined with its registry path and friendly name

# This registry follows a data-driven approach to support all AVM modules
# without duplicating code (DRY principle)

# Function to get the Terraform registry module path for a resource type
# Returns the module source path that can be used in Terraform module blocks
get_avm_module_source() {
    local resource_type="$1"
    
    case "$resource_type" in
        # API Management
        apimanagement_service) echo "Azure/avm-res-apimanagement-service/azurerm" ;;
        
        # App Services
        app_containerapp) echo "Azure/avm-res-app-containerapp/azurerm" ;;
        app_job) echo "Azure/avm-res-app-job/azurerm" ;;
        app_managedenvironment) echo "Azure/avm-res-app-managedenvironment/azurerm" ;;
        
        # App Configuration
        appconfiguration_configurationstore) echo "Azure/avm-res-appconfiguration-configurationstore/azurerm" ;;
        
        # Authorization
        authorization_roleassignment) echo "Azure/avm-res-authorization-roleassignment/azurerm" ;;
        
        # Automation
        automation_automationaccount) echo "Azure/avm-res-automation-automationaccount/azurerm" ;;
        
        # Azure VMware Solution
        avs_privatecloud) echo "Azure/avm-res-avs-privatecloud/azurerm" ;;
        
        # Azure Stack HCI
        azurestackhci_cluster) echo "Azure/avm-res-azurestackhci-cluster/azurerm" ;;
        azurestackhci_logicalnetwork) echo "Azure/avm-res-azurestackhci-logicalnetwork/azurerm" ;;
        azurestackhci_virtualmachineinstance) echo "Azure/avm-res-azurestackhci-virtualmachineinstance/azurerm" ;;
        
        # Batch
        batch_batchaccount) echo "Azure/avm-res-batch-batchaccount/azurerm" ;;
        
        # Cache
        cache_redis) echo "Azure/avm-res-cache-redis/azurerm" ;;
        
        # CDN
        cdn_profile) echo "Azure/avm-res-cdn-profile/azurerm" ;;
        
        # Certificate Registration
        certificateregistration_certificateorder) echo "Azure/avm-res-certificateregistration-certificateorder/azurerm" ;;
        
        # Cognitive Services
        cognitiveservices_account) echo "Azure/avm-res-cognitiveservices-account/azurerm" ;;
        
        # Communication
        communication_emailservice) echo "Azure/avm-res-communication-emailservice/azurerm" ;;
        
        # Compute
        compute_capacityreservationgroup) echo "Azure/avm-res-compute-capacityreservationgroup/azurerm" ;;
        compute_disk) echo "Azure/avm-res-compute-disk/azurerm" ;;
        compute_diskencryptionset) echo "Azure/avm-res-compute-diskencryptionset/azurerm" ;;
        compute_gallery) echo "Azure/avm-res-compute-gallery/azurerm" ;;
        compute_hostgroup) echo "Azure/avm-res-compute-hostgroup/azurerm" ;;
        compute_proximityplacementgroup) echo "Azure/avm-res-compute-proximityplacementgroup/azurerm" ;;
        compute_sshpublickey) echo "Azure/avm-res-compute-sshpublickey/azurerm" ;;
        compute_virtualmachine) echo "Azure/avm-res-compute-virtualmachine/azurerm" ;;
        compute_virtualmachinescaleset) echo "Azure/avm-res-compute-virtualmachinescaleset/azurerm" ;;
        
        # Container
        containerinstance_containergroup) echo "Azure/avm-res-containerinstance-containergroup/azurerm" ;;
        containerregistry_registry) echo "Azure/avm-res-containerregistry-registry/azurerm" ;;
        containerservice_managedcluster) echo "Azure/avm-res-containerservice-managedcluster/azurerm" ;;
        
        # Databricks
        databricks_workspace) echo "Azure/avm-res-databricks-workspace/azurerm" ;;
        
        # Data Factory
        datafactory_factory) echo "Azure/avm-res-datafactory-factory/azurerm" ;;
        
        # Data Protection
        dataprotection_backupvault) echo "Azure/avm-res-dataprotection-backupvault/azurerm" ;;
        dataprotection_resourceguard) echo "Azure/avm-res-dataprotection-resourceguard/azurerm" ;;
        
        # Database
        dbformysql_flexibleserver) echo "Azure/avm-res-dbformysql-flexibleserver/azurerm" ;;
        dbforpostgresql_flexibleserver) echo "Azure/avm-res-dbforpostgresql-flexibleserver/azurerm" ;;
        
        # Desktop Virtualization (AVD)
        desktopvirtualization_applicationgroup) echo "Azure/avm-res-desktopvirtualization-applicationgroup/azurerm" ;;
        desktopvirtualization_hostpool) echo "Azure/avm-res-desktopvirtualization-hostpool/azurerm" ;;
        desktopvirtualization_scalingplan) echo "Azure/avm-res-desktopvirtualization-scalingplan/azurerm" ;;
        desktopvirtualization_workspace) echo "Azure/avm-res-desktopvirtualization-workspace/azurerm" ;;
        
        # Dev Center
        devcenter_devcenter) echo "Azure/avm-res-devcenter-devcenter/azurerm" ;;
        
        # DevOps Infrastructure
        devopsinfrastructure_pool) echo "Azure/avm-res-devopsinfrastructure-pool/azurerm" ;;
        
        # Cosmos DB
        documentdb_databaseaccount) echo "Azure/avm-res-documentdb-databaseaccount/azurerm" ;;
        documentdb_mongocluster) echo "Azure/avm-res-documentdb-mongocluster/azurerm" ;;
        
        # Edge
        edge_site) echo "Azure/avm-res-edge-site/azurerm" ;;
        
        # Event Hub
        eventhub_namespace) echo "Azure/avm-res-eventhub-namespace/azurerm" ;;
        
        # Features
        features_feature) echo "Azure/avm-res-features-feature/azurerm" ;;
        
        # Hybrid Container Service
        hybridcontainerservice_provisionedclusterinstance) echo "Azure/avm-res-hybridcontainerservice-provisionedclusterinstance/azurerm" ;;
        
        # Insights
        insights_autoscalesetting) echo "Azure/avm-res-insights-autoscalesetting/azurerm" ;;
        insights_component) echo "Azure/avm-res-insights-component/azurerm" ;;
        insights_datacollectionendpoint) echo "Azure/avm-res-insights-datacollectionendpoint/azurerm" ;;
        
        # Key Vault
        keyvault_vault) echo "Azure/avm-res-keyvault-vault/azurerm" ;;
        
        # Kusto
        kusto_cluster) echo "Azure/avm-res-kusto-cluster/azurerm" ;;
        
        # Logic Apps
        logic_workflow) echo "Azure/avm-res-logic-workflow/azurerm" ;;
        
        # Machine Learning
        machinelearningservices_workspace) echo "Azure/avm-res-machinelearningservices-workspace/azurerm" ;;
        
        # Maintenance
        maintenance_maintenanceconfiguration) echo "Azure/avm-res-maintenance-maintenanceconfiguration/azurerm" ;;
        
        # Managed Identity
        managedidentity_userassignedidentity) echo "Azure/avm-res-managedidentity-userassignedidentity/azurerm" ;;
        
        # Management
        management_servicegroup) echo "Azure/avm-res-management-servicegroup/azurerm" ;;
        
        # NetApp
        netapp_netappaccount) echo "Azure/avm-res-netapp-netappaccount/azurerm" ;;
        
        # Network
        network_applicationgateway) echo "Azure/avm-res-network-applicationgateway/azurerm" ;;
        network_applicationgatewaywafpolicy) echo "Azure/avm-res-network-applicationgatewaywafpolicy/azurerm" ;;
        network_applicationsecuritygroup) echo "Azure/avm-res-network-applicationsecuritygroup/azurerm" ;;
        network_azurefirewall) echo "Azure/avm-res-network-azurefirewall/azurerm" ;;
        network_bastionhost) echo "Azure/avm-res-network-bastionhost/azurerm" ;;
        network_connection) echo "Azure/avm-res-network-connection/azurerm" ;;
        network_ddosprotectionplan) echo "Azure/avm-res-network-ddosprotectionplan/azurerm" ;;
        network_dnsresolver) echo "Azure/avm-res-network-dnsresolver/azurerm" ;;
        network_dnszone) echo "Azure/avm-res-network-dnszone/azurerm" ;;
        network_expressroutecircuit) echo "Azure/avm-res-network-expressroutecircuit/azurerm" ;;
        network_firewallpolicy) echo "Azure/avm-res-network-firewallpolicy/azurerm" ;;
        network_frontdoorwafpolicy) echo "Azure/avm-res-network-frontdoorwafpolicy/azurerm" ;;
        network_ipgroup) echo "Azure/avm-res-network-ipgroup/azurerm" ;;
        network_loadbalancer) echo "Azure/avm-res-network-loadbalancer/azurerm" ;;
        network_localnetworkgateway) echo "Azure/avm-res-network-localnetworkgateway/azurerm" ;;
        network_natgateway) echo "Azure/avm-res-network-natgateway/azurerm" ;;
        network_networkinterface) echo "Azure/avm-res-network-networkinterface/azurerm" ;;
        network_networkmanager) echo "Azure/avm-res-network-networkmanager/azurerm" ;;
        network_networksecuritygroup) echo "Azure/avm-res-network-networksecuritygroup/azurerm" ;;
        network_networkwatcher) echo "Azure/avm-res-network-networkwatcher/azurerm" ;;
        network_privatednszone) echo "Azure/avm-res-network-privatednszone/azurerm" ;;
        network_privateendpoint) echo "Azure/avm-res-network-privateendpoint/azurerm" ;;
        network_publicipaddress) echo "Azure/avm-res-network-publicipaddress/azurerm" ;;
        network_publicipprefix) echo "Azure/avm-res-network-publicipprefix/azurerm" ;;
        network_routetable) echo "Azure/avm-res-network-routetable/azurerm" ;;
        network_virtualnetwork) echo "Azure/avm-res-network-virtualnetwork/azurerm" ;;
        
        # Operational Insights
        operationalinsights_workspace) echo "Azure/avm-res-operationalinsights-workspace/azurerm" ;;
        
        # Oracle Database
        oracledatabase_cloudexadatainfrastructure) echo "Azure/avm-res-oracledatabase-cloudexadatainfrastructure/azurerm" ;;
        oracledatabase_cloudvmcluster) echo "Azure/avm-res-oracledatabase-cloudvmcluster/azurerm" ;;
        
        # Portal
        portal_dashboard) echo "Azure/avm-res-portal-dashboard/azurerm" ;;
        
        # Recovery Services
        recoveryservices_vault) echo "Azure/avm-res-recoveryservices-vault/azurerm" ;;
        
        # Red Hat OpenShift
        redhatopenshift_openshiftcluster) echo "Azure/avm-res-redhatopenshift-openshiftcluster/azurerm" ;;
        
        # Resource Graph
        resourcegraph_query) echo "Azure/avm-res-resourcegraph-query/azurerm" ;;
        
        # Resources
        resources_resourcegroup|resource_groups) echo "Azure/avm-res-resources-resourcegroup/azurerm" ;;
        
        # Search
        search_searchservice) echo "Azure/avm-res-search-searchservice/azurerm" ;;
        
        # Service Bus
        servicebus_namespace) echo "Azure/avm-res-servicebus-namespace/azurerm" ;;
        
        # SQL
        sql_managedinstance) echo "Azure/avm-res-sql-managedinstance/azurerm" ;;
        sql_server) echo "Azure/avm-res-sql-server/azurerm" ;;
        
        # Storage
        storage_storageaccount|storage_accounts) echo "Azure/avm-res-storage-storageaccount/azurerm" ;;
        
        # Web
        web_connection) echo "Azure/avm-res-web-connection/azurerm" ;;
        web_hostingenvironment) echo "Azure/avm-res-web-hostingenvironment/azurerm" ;;
        web_serverfarm) echo "Azure/avm-res-web-serverfarm/azurerm" ;;
        web_site) echo "Azure/avm-res-web-site/azurerm" ;;
        web_staticsite) echo "Azure/avm-res-web-staticsite/azurerm" ;;
        
        # Backwards compatibility aliases
        vnets) echo "Azure/avm-res-network-virtualnetwork/azurerm" ;;
        
        *)
            return 1
            ;;
    esac
    
    return 0
}

# Function to get a friendly display name for a resource type
get_avm_module_display_name() {
    local resource_type="$1"
    
    case "$resource_type" in
        # API Management
        apimanagement_service) echo "API Management Service" ;;
        
        # App Services
        app_containerapp) echo "Container App" ;;
        app_job) echo "App Job" ;;
        app_managedenvironment) echo "App Managed Environment" ;;
        
        # App Configuration
        appconfiguration_configurationstore) echo "App Configuration Store" ;;
        
        # Authorization
        authorization_roleassignment) echo "Role Assignment" ;;
        
        # Automation
        automation_automationaccount) echo "Automation Account" ;;
        
        # Azure VMware Solution
        avs_privatecloud) echo "AVS Private Cloud" ;;
        
        # Azure Stack HCI
        azurestackhci_cluster) echo "Azure Stack HCI Cluster" ;;
        azurestackhci_logicalnetwork) echo "Azure Stack HCI Logical Network" ;;
        azurestackhci_virtualmachineinstance) echo "Azure Stack HCI VM Instance" ;;
        
        # Batch
        batch_batchaccount) echo "Batch Account" ;;
        
        # Cache
        cache_redis) echo "Redis Cache" ;;
        
        # CDN
        cdn_profile) echo "CDN Profile" ;;
        
        # Certificate Registration
        certificateregistration_certificateorder) echo "Certificate Order" ;;
        
        # Cognitive Services
        cognitiveservices_account) echo "Cognitive Services Account" ;;
        
        # Communication
        communication_emailservice) echo "Communication Email Service" ;;
        
        # Compute
        compute_capacityreservationgroup) echo "Capacity Reservation Group" ;;
        compute_disk) echo "Compute Disk" ;;
        compute_diskencryptionset) echo "Disk Encryption Set" ;;
        compute_gallery) echo "Compute Gallery" ;;
        compute_hostgroup) echo "Host Group" ;;
        compute_proximityplacementgroup) echo "Proximity Placement Group" ;;
        compute_sshpublickey) echo "SSH Public Key" ;;
        compute_virtualmachine) echo "Virtual Machine" ;;
        compute_virtualmachinescaleset) echo "VM Scale Set" ;;
        
        # Container
        containerinstance_containergroup) echo "Container Instance Group" ;;
        containerregistry_registry) echo "Container Registry" ;;
        containerservice_managedcluster) echo "AKS Managed Cluster" ;;
        
        # Databricks
        databricks_workspace) echo "Databricks Workspace" ;;
        
        # Data Factory
        datafactory_factory) echo "Data Factory" ;;
        
        # Data Protection
        dataprotection_backupvault) echo "Data Protection Backup Vault" ;;
        dataprotection_resourceguard) echo "Data Protection Resource Guard" ;;
        
        # Database
        dbformysql_flexibleserver) echo "MySQL Flexible Server" ;;
        dbforpostgresql_flexibleserver) echo "PostgreSQL Flexible Server" ;;
        
        # Desktop Virtualization
        desktopvirtualization_applicationgroup) echo "AVD Application Group" ;;
        desktopvirtualization_hostpool) echo "AVD Host Pool" ;;
        desktopvirtualization_scalingplan) echo "AVD Scaling Plan" ;;
        desktopvirtualization_workspace) echo "AVD Workspace" ;;
        
        # Dev Center
        devcenter_devcenter) echo "Dev Center" ;;
        
        # DevOps Infrastructure
        devopsinfrastructure_pool) echo "DevOps Pool" ;;
        
        # Cosmos DB
        documentdb_databaseaccount) echo "Cosmos DB Account" ;;
        documentdb_mongocluster) echo "Cosmos DB MongoDB Cluster" ;;
        
        # Edge
        edge_site) echo "Azure Arc Site" ;;
        
        # Event Hub
        eventhub_namespace) echo "Event Hub Namespace" ;;
        
        # Features
        features_feature) echo "AFEC Feature" ;;
        
        # Hybrid Container Service
        hybridcontainerservice_provisionedclusterinstance) echo "AKS Arc Cluster" ;;
        
        # Insights
        insights_autoscalesetting) echo "Auto Scale Setting" ;;
        insights_component) echo "Application Insights" ;;
        insights_datacollectionendpoint) echo "Data Collection Endpoint" ;;
        
        # Key Vault
        keyvault_vault) echo "Key Vault" ;;
        
        # Kusto
        kusto_cluster) echo "Kusto Cluster" ;;
        
        # Logic Apps
        logic_workflow) echo "Logic App Workflow" ;;
        
        # Machine Learning
        machinelearningservices_workspace) echo "ML Workspace" ;;
        
        # Maintenance
        maintenance_maintenanceconfiguration) echo "Maintenance Configuration" ;;
        
        # Managed Identity
        managedidentity_userassignedidentity) echo "User Assigned Identity" ;;
        
        # Management
        management_servicegroup) echo "Management Service Group" ;;
        
        # NetApp
        netapp_netappaccount) echo "NetApp Account" ;;
        
        # Network
        network_applicationgateway) echo "Application Gateway" ;;
        network_applicationgatewaywafpolicy) echo "App Gateway WAF Policy" ;;
        network_applicationsecuritygroup) echo "Application Security Group" ;;
        network_azurefirewall) echo "Azure Firewall" ;;
        network_bastionhost) echo "Bastion Host" ;;
        network_connection) echo "VNet Gateway Connection" ;;
        network_ddosprotectionplan) echo "DDoS Protection Plan" ;;
        network_dnsresolver) echo "DNS Resolver" ;;
        network_dnszone) echo "Public DNS Zone" ;;
        network_expressroutecircuit) echo "ExpressRoute Circuit" ;;
        network_firewallpolicy) echo "Firewall Policy" ;;
        network_frontdoorwafpolicy) echo "Front Door WAF Policy" ;;
        network_ipgroup) echo "IP Group" ;;
        network_loadbalancer) echo "Load Balancer" ;;
        network_localnetworkgateway) echo "Local Network Gateway" ;;
        network_natgateway) echo "NAT Gateway" ;;
        network_networkinterface) echo "Network Interface" ;;
        network_networkmanager) echo "Virtual Network Manager" ;;
        network_networksecuritygroup) echo "Network Security Group" ;;
        network_networkwatcher) echo "Network Watcher" ;;
        network_privatednszone) echo "Private DNS Zone" ;;
        network_privateendpoint) echo "Private Endpoint" ;;
        network_publicipaddress) echo "Public IP Address" ;;
        network_publicipprefix) echo "Public IP Prefix" ;;
        network_routetable) echo "Route Table" ;;
        network_virtualnetwork|vnets) echo "Virtual Network" ;;
        
        # Operational Insights
        operationalinsights_workspace) echo "Log Analytics Workspace" ;;
        
        # Oracle Database
        oracledatabase_cloudexadatainfrastructure) echo "Oracle Exadata Infrastructure" ;;
        oracledatabase_cloudvmcluster) echo "Oracle VM Cluster" ;;
        
        # Portal
        portal_dashboard) echo "Portal Dashboard" ;;
        
        # Recovery Services
        recoveryservices_vault) echo "Recovery Services Vault" ;;
        
        # Red Hat OpenShift
        redhatopenshift_openshiftcluster) echo "OpenShift Cluster" ;;
        
        # Resource Graph
        resourcegraph_query) echo "Resource Graph Query" ;;
        
        # Resources
        resources_resourcegroup|resource_groups) echo "Resource Group" ;;
        
        # Search
        search_searchservice) echo "Search Service" ;;
        
        # Service Bus
        servicebus_namespace) echo "Service Bus Namespace" ;;
        
        # SQL
        sql_managedinstance) echo "SQL Managed Instance" ;;
        sql_server) echo "SQL Server" ;;
        
        # Storage
        storage_storageaccount|storage_accounts) echo "Storage Account" ;;
        
        # Web
        web_connection) echo "API Connection" ;;
        web_hostingenvironment) echo "App Service Environment" ;;
        web_serverfarm) echo "App Service Plan" ;;
        web_site) echo "Web/Function App" ;;
        web_staticsite) echo "Static Web App" ;;
        
        *)
            echo "$resource_type"
            ;;
    esac
}

# Export functions for use in other scripts
export -f get_avm_module_source
export -f get_avm_module_display_name
