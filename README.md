By Rob Foster

Updated 10/09/2020

# Introduction
This is the first project for the DevOps Engineer for Microsoft Azure nanodegree program from [Udacity](https://udacity.com).

### Dependencies
1. Create an [Azure Account](https://portal.azure.com) 
2. Install the [Azure command line interface](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli?view=azure-cli-latest)
3. Install [Packer](https://www.packer.io/downloads)
4. Install [Terraform](https://www.terraform.io/downloads.html)

# Instructions

## Deploy a policy
First we must create an azure policy that prevents resources from being created unless they have a tag.

To create the policy definitition:
```
az policy definition create --name tagging-policy --mode indexed --rules ./policy/policy.json
```
To assign the policy definition:
```
az policy assignment create --policy tagging-policy --name tagging-policy
```

## Create a packer template

Before running packer, create a resource group to contain your packer image:
```
az group create -n rob-rg -l uksouth
```
Create a service principal to allow packer to build templates in azure:
az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"

On the machine you are running packer from, create the following environment variables using the output from the above command, along with your subscription ID:
CLIENT_ID

CLIENT_SECRET

TENANT_ID

SUBSCRIPTION_ID

Create your template:
packer build ./packer/server.json

## Provision resources using terraform

Change into the terraform directory:
```
cd terraform
```
Download plugins:
```
terraform init
```
Customize the deployment by setting variables in the terraform.tfvars file, and then provison the resources:
```
terraform apply
```



# Files
