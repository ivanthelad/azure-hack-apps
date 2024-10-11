
source .env
## Function to print colored messages
colored_echo() {
    local message=$1
    local color_code=$2
    echo -e "\033[1;${color_code}m${message}\033[0m"
}
## Function to print environment variables
print_env_vars() {
    colored_echo "Environment Variables:" 35
    colored_echo "RESOURCE_GROUP: $RESOURCE_GROUP" 35
    colored_echo "LOCATION: $LOCATION" 35
    colored_echo "ACR_NAME: $ACR_NAME" 35
}

### 
# Create Event Hubs namespace
az eventhubs namespace create --resource-group $RESOURCE_GROUP --name $NAMESPACE_NAME --location $LOCATION --sku Basic
# Create Event Hub
az eventhubs eventhub create --resource-group $RESOURCE_GROUP --namespace-name $NAMESPACE_NAME --name $EVENTHUB_NAME
## Create Event Hub Authorization Rule
az eventhubs eventhub authorization-rule create --resource-group $RESOURCE_GROUP --namespace-name $NAMESPACE_NAME --eventhub-name $EVENTHUB_NAME --name listensend --rights Listen Send
az eventhubs eventhub authorization-rule keys list --resource-group $RESOURCE_GROUP --namespace-name $NAMESPACE_NAME --eventhub-name $EVENTHUB_NAME --authorization-rule-name=listensend --query "primaryConnectionString" --output tsv



## CosmosDB
az cosmosdb create --name $COSMOSDB_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --locations  regionName=$LOCATION
az cosmosdb sql database create --account-name $COSMOSDB_ACCOUNT_NAME  --resource-group $RESOURCE_GROUP --name $DATABASE_NAME
az cosmosdb sql container create --account-name $COSMOSDB_ACCOUNT_NAME  --resource-group $RESOURCE_GROUP  --database-name $DATABASE_NAME --name $CONTAINER_NAME --partition-key-path "/repairPartId"   --throughput "200"


# app config
az appconfig create --resource-group $RESOURCE_GROUP --name $APPCONFIG_NAME --location $LOCATION
## Storage account
az storage account create --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --location $LOCATION --sku Standard_LRS
az storage account show-connection-string --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --query "connectionString" --output tsv
## Key Vault

# Retrieve Event Hub Connection String
event_hub_connection_string=$(az eventhubs eventhub authorization-rule keys list --resource-group $RESOURCE_GROUP --namespace-name $NAMESPACE_NAME --eventhub-name $EVENTHUB_NAME --authorization-rule-name=listensend --query "primaryConnectionString" --output tsv)
# Retrieve Blob Storage Connection String
blob_connection_string=$(az storage account show-connection-string --name $STORAGE_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --query "connectionString" --output tsv)
# Retrieve App Configuration Connection String
app_config_connection_string=$(az appconfig credential list --resource-group $RESOURCE_GROUP --name $APPCONFIG_NAME --query "[0].connectionString" --output tsv)
# Set environment variables
export ApplicationInsights__ConnectionString=$app_insights_connection_string
export EventHub__EventHubConnectionString=$event_hub_connection_string
export EventHub__BlobConnectionString=$blob_connection_string
export AppConfiguration__ConnectionString=$app_config_connection_string
