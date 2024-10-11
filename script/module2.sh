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

## Print environment variables
print_env_vars
## 1. Create a resource group
colored_echo "Creating resource group: $RESOURCE_GROUP in location: $LOCATION" 32
az group create --name $RESOURCE_GROUP --location $LOCATION

## 2. Create an Azure Container Registry
colored_echo "Creating Azure Container Registry: $ACR_NAME in resource group: $RESOURCE_GROUP" 32
az acr create --resource-group $RESOURCE_GROUP --name $ACR_NAME --sku Basic --location $LOCATION --admin-enabled=true 

az acr update --name $ACR_NAME  --admin-enabled true
## 3. Build and push images to the Azure Container Registry
cd ../
colored_echo "Building and pushing image: acacontonancebackend:v1 to $ACR_NAME.azurecr.io" 32
az acr build -t acacontonancebackend:v1 -r $ACR_NAME.azurecr.io --no-logs -f Contonance.Backend/Dockerfile .

colored_echo "Building and pushing image: acawarehouse:v1 to $ACR_NAME.azurecr.io" 32
az acr build -t acawarehouse:v1 -r $ACR_NAME.azurecr.io --no-logs -f EnterpriseWarehouse.Backend/Dockerfile .

colored_echo "Building and pushing image: acawebportal:v1 to $ACR_NAME.azurecr.io" 32
az acr build -t acawebportal:v1 -r $ACR_NAME.azurecr.io --no-logs -f Contonance.WebPortal/Server/Dockerfile .
cd script
## 4. List the images in the Azure Container Registry
colored_echo "Listing images in Azure Container Registry: $ACR_NAME" 32
az acr list -o table
az acr repository list -n $ACR_NAME