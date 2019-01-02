#!/bin/sh
#
# Initialize Terraform & Connect Supporting Storage Account
# Uses the following Command-Line Parameters:
# $1  - Azure Location (e.g. centralus)
# $2  - Azure Key Vault (must be in Azure Location, be accessible from Current Subscription/Tenant)
# $3  - Azure AD App Id/Service Principal (must be Contributor in Target Azure Resource Groups)
# $4  - Azure Storage Account for Terraform State (assumes Container named "tfstate" created)
#
# Set Required Environment Variables (will use current/defaul Azure Subscription/Tenant)
#
echo "--- Setting environment variables for Terraform"
export ARM_LOCATION=$1
export ARM_KEY_VAULT=$2
export ARM_CLIENT_ID = $3
export ARM_CLIENT_SECRET=$(az keyvault secret show --name $ARM_CLIENT_ID --vault-name $ARM_KEY_VAULT --query "value" --output tsv)
export ARM_SUBSCRIPTION_ID=$(az account show --query "{subscriptionId:id}" --output tsv)
export ARM_TENANT_ID=$(az account show --query "{tenantId:tenantId}" --output tsv)
export ARM_STORAGE_ACCOUNT=$4
export ARM_STORAGE_ACCT_KEY=$(az keyvault secret show --name $ARM_STORAGE_ACCOUNT --vault-name $ARM_KEY_VAULT --query "value" --output tsv)
#
echo "--- Initializing Terraform"
terraform init -backend-config="storage_account_name=$ARM_STORAGE_ACCOUNT" -backend-config="container_name=tfstate" -backend-config="access_key=$ARM_STORAGE_ACCT_KEY" -backend-config="key=codelab.microsoft.tfstate"