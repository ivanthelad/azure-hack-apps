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
  colored_echo "CONTAINERAPPS_ENVIRONMENT: $CONTAINERAPPS_ENVIRONMENT" 35
  colored_echo "LOG_ANALYTICS_WORKSPACE: $LOG_ANALYTICS_WORKSPACE" 35
  
}

## Print environment variables
print_env_vars

## Log analytics
colored_echo "Creating Log Analytics Workspace" 32
az monitor log-analytics workspace create --resource-group $RESOURCE_GROUP --workspace-name $LOG_ANALYTICS_WORKSPACE --location $LOCATION
colored_echo "Log Analytics Workspace created" 32
## Get the workspace key and id
workspacekey=$(az monitor log-analytics workspace get-shared-keys \
    --resource-group $RESOURCE_GROUP \
    --workspace-name $LOG_ANALYTICS_WORKSPACE \
    --query primarySharedKey \
    --output tsv)
workspaceid=$(az monitor log-analytics workspace show \
    --resource-group $RESOURCE_GROUP \
    --workspace-name $LOG_ANALYTICS_WORKSPACE \
    --query customerId \
    --output tsv)
colored_echo "Log Analytics Workspace Key: $workspacekey" 35
colored_echo "Log Analytics Workspace ID: $workspaceid" 35
## Create an Azure Container Apps environment
az containerapp env create \
    --name $CONTAINERAPPS_ENVIRONMENT \
    --resource-group $RESOURCE_GROUP \
    --location $LOCATION \
    --logs-destination log-analytics \
    --logs-workspace-key $workspacekey --logs-workspace-id $workspaceid
## Create an Azure Container Apps service

## 2D array containing image and container app name pairs
declare -a container_apps=(
  "acrazhasa1.azurecr.io/acacontonancebackend:v5 contonance-backend internal 8080"
  "acrazhasa1.azurecr.io/acawarehouse:v5 enterprise-warehouse-backend internal 8080"
  "acrazhasa1.azurecr.io/acawebportal:v5 contonance-web-portal external 8080"
  # Add more pairs as needed
)
colored_echo "Retrieving ACR credentials" 32
ACR_CREDENTIALS=$(az acr credential show --name "$ACR_NAME" -o json)
ACR_USERNAME=$(echo "$ACR_CREDENTIALS" | jq -r '.username')
ACR_PASSWORD=$(echo "$ACR_CREDENTIALS" | jq -r '.passwords[0].value')
## Loop over the 2D array
## Loop over the 2D array
for app in "${container_apps[@]}"; do
  IFS=' ' read -r IMAGE CONTAINER_APP_NAME VISIBILITY PORT <<< "$app"
  
  colored_echo "Creating container app: $CONTAINER_APP_NAME with image: $IMAGE, visibility: $VISIBILITY, port: $PORT" 32
  
  az containerapp create \
    --name "$CONTAINER_APP_NAME" \
    --resource-group "$RESOURCE_GROUP" \
    --environment "$CONTAINERAPPS_ENVIRONMENT" \
    --image "$IMAGE" \
    --ingress "$VISIBILITY" \
    --target-port "$PORT" \
    --registry-username "$ACR_USERNAME" \
    --registry-password "$ACR_PASSWORD" \
    --registry-server $ACR_NAME.azurecr.io \
    --min-replicas 1  --max-replicas 10 \
    --env-vars "ENV_VAR1_NAME=demo" "ENV_VAR2_NAME=demo2"
    colored_echo "Container app: $CONTAINER_APP_NAME created" 32
done
## List the container apps
colored_echo "Listing container apps" 32
az containerapp list --resource-group $RESOURCE_GROUP --environment $CONTAINERAPPS_ENVIRONMENT -o table

