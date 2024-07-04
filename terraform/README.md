# terraform-2bclouds

# This repo for Terraform  modules to create the Azure resources:

1- Azure Virtual-network (VN) resource

2-Azure Virtual machine (VM) resource

3-Azure Container Registry (ACR) resource

4-Azure Kubernetes Service (AKS) resource

5- Azure Key Vault resource



# to run the Terraform Module you should access the directory for each resources and then run the following command:

```
export ARM_CLIENT_ID="<client-id>"
export ARM_CLIENT_SECRET="<client-secret>"
export ARM_SUBSCRIPTION_ID="<subscription-id>"
export ARM_TENANT_ID="<tenant-id>"


terraform init 

terraform plan -var-file terraform.tfvars

terraform apply -var-file terraform.tfvars

```    


