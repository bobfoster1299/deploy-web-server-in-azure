By Rob Foster

Updated 10/09/2020

# Introduction
This is my submission for the 'Deploying a Web Server in Azure' project as part of the 'DevOps Engineer for Microsoft Azure' nanodegree program from [Udacity](https://udacity.com).

It does the following:
- Deploys an azure policy that prevents resources from being created within the subscription unless they have a tag.
- Create a VM template using packer.
- Uses terraform to provision the following resources in azure:
  - Availability set
  - OS disks
  - Data disks
  - Load balancer
  - Network interfaces
  - Network security groups
  - Public IP address
  - Virtual Machines
  - Virtual Network

# Instructions

## Deploy the policy

To create the policy definitition:
```
az policy definition create --name tagging-policy --mode indexed --rules policy.json
```
To assign the policy definition:
```
az policy assignment create --policy tagging-policy --name tagging-policy
```

## Create a template using packer

Before running packer, create a resource group to contain all the resources:
```
az group create -n rob-rg -l uksouth
```
Create a service principal to allow packer to build templates in azure:
```
az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
```

On the machine you are running packer from, set the following environment variables using the output from the above command, along with your subscription ID:

CLIENT_ID, CLIENT_SECRET, TENANT_ID, SUBSCRIPTION_ID

Create the template in azure:
```
packer build packer.json
```

## Provision resources using terraform

Download plugins:
```
terraform init
```
Customize the deployment by setting variables in the terraform.tfvars file. By changing the number_of_vms variable you can select how many VMs you want to build.

Provison the resources:
```
terraform apply
```
Once you are finished with your packer image you can delete it:
```
az image delete --name rob-packer-image7 --resource-group rob-rg
```
Once your resources are no longer required, delete them:
```
terraform destroy
```