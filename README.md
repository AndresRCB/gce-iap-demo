# GCP Identity-Aware Proxy (IAP) over External and Internal Load Balancers

A demo of how IAP can secure internal applications via external and internal Google Cloud Load Balancers. This document follows concepts and takes resources from the following links:
- [Identity-Aware Proxy Concepts](https://cloud.google.com/iap/docs/concepts-overview)
- [Global HTTP Load Balancer Terraform Module](https://github.com/terraform-google-modules/terraform-google-lb-http)


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
support_email = "YOUR_EMAIL@email.com"
```
3. Bring up the project and resources
```sh
terraform init && terraform apply -auto-approve
```

### Steps

4. A project with all the resources that you need was created for you, so you can now check the IP address (LOAD_BALANCER_IP) of your global load balancer using the following command:
```sh
terraform output load_balancer_ip
```
5. Go to your browser using the IP address from above: https://LOAD_BALANCER_IP/
6. Your browser will say that the site is "not safe" because we used a self-signed certificate, but traffic will still be encrypted (click on "advanced" or other options to continue to the site)
7. You'll be asked to select an account to proceed (the account with which you logged into your browser session), so select the one that you want to grant access to later on
8. You should see that you don't have access to the web application that terraform deployed because IAP hasn't been configured to grant access to your account
9. Go to [Cloud IAP's configuration page in the Google Cloud console](https://console.cloud.google.com/security/iap) and add your account (and any others to which you wish to grant access) to the load balancer ([you do this by granting the `IAP-secured Web App User` role](https://cloud.google.com/iap/docs/concepts-overview#authorization) to entities/accounts that should have access)
10. Go to the webapp (https://LOAD_BALANCER_IP) using your browser again and you should see the text for the instance that your request is reaching (since it's a 3-instance Managed Instance Group, you'll see three different instance names if you refresh the site multiple times)
11. You can also grant access to IAP resource with terraform, and even grant access to service accounts to secure your services

## Cleaning up
You have two options:
- `terraform destroy -auto-approve` (takes 15 to 30 minutes to run and might fail depending on what you created/changed manually)
- Shut down the Google Cloud Project (takes no time)