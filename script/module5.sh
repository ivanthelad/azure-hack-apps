
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
    colored_echo "APP_INSIGHTS_NAME: $APP_INSIGHTS_NAME" 35
    colored_echo "LOG_ANALYTICS_WORKSPACE: $LOG_ANALYTICS_WORKSPACE" 35
}


## Creating app insights 
colored_echo " Creating app insights " 32

az monitor app-insights component create --app $APP_INSIGHTS_NAME --location $LOCATION --resource-group $RESOURCE_GROUP --kind web --application-type web --workspace $LOG_ANALYTICS_WORKSPACE
colored_echo " Getting app insights connection String " 32
# Retrieve App Configuration Connection String. used by all but not yet
app_insights_connection_string=$(az monitor app-insights component show --app $APP_INSIGHTS_NAME --resource-group $RESOURCE_GROUP --query "connectionString" --output tsv)

colored_echo " Set the webportal ApplicationInsights__ConnectionString env variables " 32
colored_echo "Set the backendApplicationInsights__ConnectionString env variables "
## Set the webportal ApplicationInsights__ConnectionString env variables 
  az containerapp update \
    --name "contonance-web-portal" \
    --resource-group "$RESOURCE_GROUP" \
    --set-env-vars \
      ApplicationInsights__ConnectionString="$app_insights_connection_string" 

      colored_echo "Set the backendApplicationInsights__ConnectionString env variables " 32

## Set the backendApplicationInsights__ConnectionString env variables 

  az containerapp update \
    --name "contonance-backend" \
    --resource-group "$RESOURCE_GROUP" \
    --set-env-vars \
      ApplicationInsights__ConnectionString="$app_insights_connection_string" 


colored_echo " Set the backend ApplicationInsights__ConnectionString env variables " 32

## Set the warehour ApplicationInsights__ConnectionString env variables 
  az containerapp update \
    --name "enterprise-warehouse-backend" \
    --resource-group "$RESOURCE_GROUP" \
    --set-env-vars \
      ApplicationInsights__ConnectionString="$app_insights_connection_string"