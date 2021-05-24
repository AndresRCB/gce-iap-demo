# GCP Identity-Aware Proxy (IAP) over External and Internal Load Balancers

A demo of how IAP can secure internal applications via external and internal Google Cloud Load Balancers. This document follows concepts and takes resources from the following links:
- [Identity-Aware Proxy Concepts](https://cloud.google.com/iap/docs/concepts-overview)
- [Cloud Foundations Toolkit in Terraform - IAP Bastion](https://github.com/terraform-google-modules/terraform-google-bastion-host/tree/master/modules/iap-tunneling)


This demo will create a project for you, so you can start from an empty cloud shell session at [shell.cloud.google.com](shell.cloud.google.com).

## Running the Demo

### Setup
1. Go to [Google Cloud Shell](https://shell.cloud.google.com) and clone this repo
2. Go into the repo's folder and update the `main.tf` file with your values (`folder_id` is optional):
```sh
project_id= "unique-project-id"
billing_account = "FFFFF-FFFFF-FFFFF"
org_id = "333333333333"
[OPTIONAL] folder_id = "111111111111"
```
3. Bring up the project and resources
```sh
terraform init && terraform apply -auto-approve
```

### Steps

4. TODO
5. TODO

## Cleaning up
You have two options:
- `terraform destroy -auto-approve` (takes 15 to 30 minutes to run and might fail depending on what you created/changed manually)
- Shut down the Google Cloud Project (takes no time)