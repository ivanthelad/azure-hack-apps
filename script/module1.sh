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
}

az group create --name $RESOURCE_GROUP --location $LOCATION
