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