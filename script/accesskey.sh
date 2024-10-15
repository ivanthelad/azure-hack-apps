source .env
### enabling key access against azure storage 

az storage account update     --name $STORAGE_ACCOUNT_NAME     --resource-group $RESOURCE_GROUP     --allow-shared-key-access true

az resource update --ids $(az cosmosdb show --name $COSMOSDB_ACCOUNT_NAME --resource-group $RESOURCE_GROUP --query "id" --output tsv) --set properties.disableLocalAuth=false



