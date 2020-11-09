By Rob Foster

Updated 11/09/2020

# Introduction
This is my submission for the 'Deploying a Web Server in Azure' project as part of the 'DevOps Engineer for Microsoft Azure' nanodegree program from [Udacity](https://udacity.com).

It does the following:
- Deploys an azure policy that prevents resources from being created within the subscription unless they have a tag.
- Uses packer to create a VM template which hosts a website that displays the message 'Hello World!'
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

Create the policy definitition:
```
az policy definition create --name tagging-policy --mode indexed --rules policy.json
```
Assign the policy definition:
```
az policy assignment create --policy tagging-policy --name tagging-policy
```

## Create a template using packer

Login to azure:
```
az login
```

Before running packer, create a resource group to contain all the resources:
```
az group create -n rob-rg -l uksouth
```
Create a service principal to allow packer to build templates in azure:
```
az ad sp create-for-rbac --query "{ client_id: appId, client_secret: password, tenant_id: tenant }"
```

On the machine you are running packer from, set the following environment variables using the output from the above command, along with your subscription ID:

- CLIENT_ID
- CLIENT_SECRET
- TENANT_ID
- SUBSCRIPTION_ID

Customize the following values in [server.json](server.json):
- managed_image_resource_group_name - The name of the resource group you created in azure
- managed_image_name - The name to give to your template
- os_type - The OS type of the base image
- image_publisher - The publisher of the base image
- image_offer -  The offer of the base image
- image_sku - The SKU of the base image
- location - The region of the image
- vm_size - The size of the VM
- azure_tags:
  - environment: Environment tag, e.g. prod, dev
  - project - Project tag
  - owner - Owner tag
  - image - Image tag
- provisioners:
  - inline - The commands to execute on your template

Create the template in azure:
```
packer build server.json
```

## Provision resources using terraform

Download plugins:
```
terraform init
```
The following settings can be customized by editing the variables in the [terraform.tfvars](terraform.tfvars) file:
- prefix - The prefix which should be used for the names of all resources in this deployment
- location - The azure region in which all resources in this deployment should be created
- number_of_vms - Number of VMs to provision
- admin_username - The admin username for the VMs
- admin_password - The admin password for the VMs
- address_space - VNET address space
- subnet - Subnet address space
- environment - Environment tag, e.g. prod, dev
- project - Project tag
- owner - Owner tag
- image - The VM image to deploy (should match the name of the image created by packer)

Provison the resources:
```
terraform apply
```
Once your resources are no longer required, delete them:
```
terraform destroy
```
Finally, you can delete the resource group:
```
az group delete -n rob-rg
```
