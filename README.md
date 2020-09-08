POLICY

Create policy definitition:
az policy definition create --name tagging-policy --mode indexed --rules policy.json --params params.json

Assign policy definition (assigned to RG rather than whole subscription for now):
az policy assignment create --policy tagging-policy --resource-group rob-rg4 --name tagging-policy

POLICY TAKES 30 MINS OR SO TO APPLY: https://docs.microsoft.com/en-us/azure/governance/policy/troubleshoot/general