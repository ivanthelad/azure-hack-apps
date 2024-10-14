## Source the .env file
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
    colored_echo "LOAD_TEST_NAME: $LOAD_TEST_NAME" 35
    colored_echo "LOAD_TEST_URL: $LOAD_TEST_URL" 35
}

## Print environment variables
print_env_vars

## Create a load test resource
colored_echo "Creating load test resource: $LOAD_TEST_NAME" 32

LOAD_TEST_URL=$(az containerapp show --name "$CONTAINER_APP_NAME" --resource-group "$RESOURCE_GROUP" --query "properties.configuration.ingress.fqdn" -o tsv)

## Create a load test configuration
colored_echo "Creating load test configuration for URL: $LOAD_TEST_URL" 32
cat <<EOF > loadtest.yaml
version: v0.1
testName: "SampleLoadTest"
description: "Load test for GET URL"
engineInstances: 1
testDuration: "5m"
loadProfile:
  - loadType: "ramp"
    start: 1
    end: 10
    duration: "2m"
  - loadType: "constant"
    value: 10
    duration: "3m"
requests:
  - url: "$LOAD_TEST_URL"
    method: "GET"
EOF
az load test create --test-id "$LOAD_TEST_NAME" --name "$LOAD_TEST_NAME" --resource-group "$RESOURCE_GROUP" --load-test-config-file loadtest.yaml

## Upload the load test configuration
colored_echo "Uploading load test configuration" 32
# az load test upload --name "$LOAD_TEST_NAME" --resource-group "$RESOURCE_GROUP" --file-path loadtest.yaml

## Run the load test
colored_echo "Running the load test" 32
#az load test run --name "$LOAD_TEST_NAME" --resource-group "$RESOURCE_GROUP"