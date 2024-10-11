## Source the .env file
source .env

## Function to print colored messages
colored_echo() {
  local message=$1
  local color_code=$2
  echo -e "\033[1;${color_code}m${message}\033[0m"
}

## Function to print environment variables


## Print environment variables
print_env_vars

## Get the list of container apps
colored_echo "Retrieving list of container apps in resource group: $RESOURCE_GROUP" 32
CONTAINER_APPS=$(az containerapp list  --query "[].name" -o tsv)

## Loop over the list of container apps and delete each one
for app in $CONTAINER_APPS; do
  colored_echo "Shutting down container app: $app" 31
  az containerapp delete --name "$app" --resource-group "$RESOURCE_GROUP" --yes
done

colored_echo "All container apps have been shut down." 32