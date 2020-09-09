3. Deploy a policy - COMPLETED!

Create policy definitition:
az policy definition create --name tagging-policy --mode indexed --rules policy.json

Assign policy definition:
az policy assignment create --policy tagging-policy --name tagging-policy



4. Packer template

Create image:
packer build server.json

WEBSERVER DOESN'T SEEM TO RUN AFTER BUILDING


5. Terraform template

Download plugins:
terraform init


TERRAFORM MANUAL BUILD - THIS WORKS IN ROB-RG6!
RG - rob-rg6
VNET - rob-vnet1 - 10.2.0.0/16
Subnet - rob-subnet1 - 10.2.0.0/24
NSG - rob-nsg1 - NEEDS RULES. IS THIS FOR THE SUBNET OR THE NICS? SHOULD ALL NICS ATTACH TO IT?
NIC - rob-vm189
      VNET - rob-vnet1
      Subnet - rob-subnet1
      NSG - rob-nsg1
PIP - rob-pip1
      SKU: Standard
      DNS Name Label: rob-udacity
      Associated to rob-lb1
      Availability Zone: Zone-redundant
LB - rob-lb1
      Type - public
      SKU - Standard (REQUIRES NSG TO WORK!)
      PIP - rob-pip1
      LBFrontEnd -  LoadBalanderFrontEnd
                    PIP - rob-pip1
      BackendPools - rob-backendpool1 
AVSet - rob-avset1
VM1 - rob-vm1
      AVSet - rob-avset1
      AuthType: password
      Username: adminuser
      Password: Ymn$DJ5Igv#0U0d906HZ
      InboundPorts: 22, 80
      OSDiskType: Standard HDD
      DataDisk: rob-vm1_DataDisk_0
                SourceType: Empty
                StorageType: Standard HDD
                Size: 10GB
      VNET: rob-vnet1
      Subnet: rob-subnet1
      PIP: none
      NSG (for NIC):  Advanced
                      rob-nsg1
      LB Options: Azure Load Balancer
                  LB: rob-lb1
                  Backend Pool: rob-backendpool1
      NIC: rob-vm189
Disk -  rob-vm1_OsDisk_xxxxxxxxx
        rob-vm1_DataDisk_0
Health Probe -  roblb-health
                Protocol: TCP
                Port: 80
                Interval: 5
                Unhealthy Threshold: 2
                Used by: rob-lbrule
LBRule -  rob-lbrule
          Frontend IP: LoadBalancerFrontEnd
          Protocol: TCP
          Port: 80
          Backend port: 80
          Backend Pool: rob-backendpool1
          Health Probe: rob-health
