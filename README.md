# GCP Identity-Aware Proxy (IAP) over External Load Balancers

A demo of how IAP can secure internal applications via external and internal Google Cloud Load Balancers. This document follows concepts and takes resources from the following links:
- [Identity-Aware Proxy Concepts](https://cloud.google.com/iap/docs/concepts-overview)
- [Global HTTP Load Balancer Terraform Module](https://github.com/terraform-google-modules/terraform-google-lb-http)


This demo will create a project for you, so you can start from an empty cloud shell session at [shell.cloud.google.com](shell.cloud.google.com).

## Running the Demo

### Setup
1. Go to [Google Cloud Shell](https://shell.cloud.google.com), clone this repo and `cd` into it
2. Create a `terraform.tfvars` file and use the example below for contents, replacing the placeholder values with your active billing account, organization, etc. (`folder_id` is optional):
```sh
project_id= "unique-project-id"
billing_account = "FFFFF-FFFFF-FFFFF"
org_id = "333333333333"
[OPTIONAL] folder_id = "111111111111"
support_email = "YOUR_EMAIL@YOUR_DOMAIN.com"
```
3. Bring up the project and resources
```sh
terraform init && terraform apply -auto-approve
```

### Steps

4. A project with all the resources that you need was created for you, so you can now check the IP address of your global load balancer (LOAD_BALANCER_IP) using the following command:
```sh
terraform output load_balancer_ip
```
5. Go to your browser using the IP address obtained above: `https://LOAD_BALANCER_IP/`
6. Your browser will say that the site is "not safe" because we used a self-signed certificate, but traffic will still be encrypted (click on "advanced" or "other options" to continue to the site)
7. You'll be asked to select an account to proceed (the account with which you logged into your browser session), so select the one to which you want to grant access later on (your account must be part of the same organization as your GCP project)
8. You should see that you don't have access to the web application that terraform deployed because IAP hasn't been configured to grant access to your account
9. Go to [Cloud IAP's configuration page in the Google Cloud console](https://console.cloud.google.com/security/iap) and add your account (and any others to which you wish to grant access) to the load balancer:
    - [You do this by granting the `IAP-secured Web App User` role](https://cloud.google.com/iap/docs/concepts-overview#authorization) to entities/accounts that should have access
    - **NOTE**: the change will take 1-2 minutes to propagate, so you'll see the "you don't have access" screen if you refresh your browser right away
10. Go to the webapp (https://LOAD_BALANCER_IP) using your browser again and you should see the text for the instance that your request is reaching (since it's a 3-instance Managed Instance Group, you'll see three different instance names if you refresh the site multiple times)
11. You can also grant access to IAP resources with terraform, and even grant access to service accounts to secure your services

## Cleaning up
You have two options:
- `terraform destroy -auto-approve` (takes a few minutes to run and might fail depending on what you created/changed manually)
- Shut down the Google Cloud Project (takes no time)
