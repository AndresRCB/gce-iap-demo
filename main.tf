provider "google" {
    project = var.project_id
    region  = var.region
    zone = var.zone
}

provider "google-beta" {
    project = var.project_id
    region  = var.region
    zone = var.zone
}

# data "google_client_config" "default" {}

module "project" {
    source                        = "terraform-google-modules/project-factory/google"
    name                          = var.project_id
    billing_account               = var.billing_account
    org_id                        = var.org_id
    folder_id                     = var.folder_id
    random_project_id             = false

    activate_apis           = [
        "compute.googleapis.com",
        "iap.googleapis.com",
        "cloudbilling.googleapis.com"
    ]
}

resource "google_compute_network" "network" {
    name                    = var.network_name
    auto_create_subnetworks = false
    
    depends_on = [
        module.project,
    ]
}

resource "google_compute_subnetwork" "subnetwork" {
    name          = var.subnet_name
    ip_cidr_range = "172.16.0.0/16"
    region        = var.region
    network       = google_compute_network.network.self_link
    private_ip_google_access   = true
}

resource "google_compute_subnetwork" "proxy_only_subnet" {
    provider = google-beta

    name          = "proxy-only-subnet"
    ip_cidr_range = "10.129.0.0/23"
    region        = var.region
    purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
    role          = "ACTIVE"
    network       = google_compute_network.network.self_link
}

resource "google_compute_firewall" "fw-allow-proxies" {
    name          = "fw-allow-proxies"
    network       = google_compute_network.network.self_link

    allow {
        protocol    = "tcp"
        ports       = ["80", "8080", "443", "8443"]
    }

    source_ranges = [
        google_compute_subnetwork.proxy_only_subnet.ip_cidr_range,
    ]
}

resource "google_compute_firewall" "fw-allow-health-check" {
    name          = "fw-allow-health-check"
    network       = google_compute_network.network.self_link

    allow {
        protocol    = "tcp"
    }

    source_ranges = ["130.211.0.0/22","35.191.0.0/16"]
}


## TODO: CREATED INSTANCE BUT NEED AN INSTANCE GROUP INSTEAD
# resource "google_compute_instance" "backend_instance" {
#     name         = "backend-instance"
#     # This is just an n2d-standard-2 instance, but this nomenclature shows how to create a custom instance
#     machine_type = "n2d-custom-2-8192"
#     allow_stopping_for_update = true
# 
#     boot_disk {
#         initialize_params {
#             image = "debian-cloud/debian-10"
#             size  = 200
#             type = "pd-ssd"
#         }
#     }
# 
#     network_interface {
#         subnetwork = google_compute_subnetwork.subnetwork.self_link
#     }
# 
#     metadata_startup_script = <<SCRIPT
#       #! /bin/bash
#      apt-get update
#      apt-get install apache2 -y
#      a2ensite default-ssl
#      a2enmod ssl
#      vm_hostname="$(curl -H "Metadata-Flavor:Google" \
#      http://169.254.169.254/computeMetadata/v1/instance/name)"
#      echo "Page served from: $vm_hostname" | \
#      tee /var/www/html/index.html
#      systemctl restart apache2'
#     SCRIPT
# }