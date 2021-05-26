variable "org_id" {
    type = string
    description = "An existing organization ID for the demo project"
}

variable "project_id" {
    type = string
    description = "a New and unique project ID for the demo project to be created"
}

variable "billing_account" {
    type = string
    description = "An existing billing account to be charged for this demo"
}

variable "folder_id" {
    type = string
    description = "An existing folder ID for the demo project to be created into"
    default = ""
}

variable "support_email" {
    type = string
    description = "support email to reach out to regarding oauth issues"
}

variable "application_name" {
    type = string
    default = "Cloud IAP protected Application"
    description = "Application name to show in account authorization screen"
}

variable "client_display_name" {
    type = string
    default = "Test IAP Client"
    description = "IAP client name"
}

variable "region" {
    type = string
    default = "us-central1"
    description = "GCP region to create resources"
}

variable "zone" {
    type = string
    default = "us-central1-a"
    description = "GCP zone to create resources"
}

variable "network_name" {
    type = string
    default = "iap-demo-network"
    description = "Name of the network that will be created for the demo"
}

variable "subnet_name" {
    type = string
    default = "iap-demo-subnet"
    description = "Name of the subnet that will be created for the backend instance"
}