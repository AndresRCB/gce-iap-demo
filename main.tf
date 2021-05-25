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

resource "google_compute_firewall" "fw-allow-health-check" {
    name          = "fw-allow-health-check"
    network       = google_compute_network.network.self_link

    allow {
        protocol    = "tcp"
    }

    source_ranges = ["130.211.0.0/22","35.191.0.0/16"]

    target_tags = ["allow-health-checks"]
}

resource "google_compute_router" "default" {
  name    = "lb-https-redirect-router"
  network = google_compute_network.network.self_link
  region  = var.region
}

module "cloud-nat" {
  source     = "terraform-google-modules/cloud-nat/google"
  version    = "1.4.0"
  router     = google_compute_router.default.name
  project_id = module.project.project_id
  region     = var.region
  name       = "cloud-nat-lb-https-redirect"
}


module "mig_template" {
  source     = "terraform-google-modules/vm/google//modules/instance_template"
  version    = "6.4.0"
  network    = google_compute_network.network.self_link
  subnetwork = google_compute_subnetwork.subnetwork.self_link
  machine_type    = "e2-custom-2-8192"
  disk_size_gb = 200
  disk_type = "pd-ssd"
  # source_image = "debian-10"
  source_image_family = "debian-10"
  source_image_project = "debian-cloud"
  service_account = {
    email  = ""
    scopes = ["cloud-platform"]
  }
  name_prefix    = var.network_name
  startup_script = <<SCRIPT
      #! /bin/bash
      apt-get update
      apt-get install apache2 -y
      a2ensite default-ssl
      a2enmod ssl
      vm_hostname="$(curl -H "Metadata-Flavor:Google" \
      http://169.254.169.254/computeMetadata/v1/instance/name)"
      echo "Page served from: $vm_hostname" | \
      tee /var/www/html/index.html
      systemctl restart apache2'
    SCRIPT
  tags = [
    var.network_name,
    module.cloud-nat.router_name,
    "allow-health-checks"
  ]
}

module "mig" {
  source            = "terraform-google-modules/vm/google//modules/mig"
  version           = "6.4.0"
  instance_template = module.mig_template.self_link
  region            = var.region
  hostname          = var.network_name
  target_size       = 3
  named_ports = [{
    name = "http",
    port = 80
  }]
  network    = google_compute_network.network.self_link
  subnetwork = google_compute_subnetwork.subnetwork.self_link

  depends_on = [
        module.project,
    ]
}

module "gce-lb-http" {
  source            = "GoogleCloudPlatform/lb-http/google"
  version           = "~> 5.1.0"

  project           = module.project.project_id
  name              = "group-http-lb"
  target_tags       = [var.network_name]
  firewall_networks    = [google_compute_network.network.name]
  ssl                  = true
  ssl_certificates     = [google_compute_ssl_certificate.example.self_link]
  use_ssl_certificates = true
  https_redirect       = true

  backends = {
    default = {
      description                     = null
      protocol                        = "HTTP"
      port                            = 80
      port_name                       = "http"
      timeout_sec                     = 10
      enable_cdn                      = false
      custom_request_headers          = null
      security_policy                 = null

      connection_draining_timeout_sec = null
      session_affinity                = null
      affinity_cookie_ttl_sec         = null

      health_check = {
        check_interval_sec  = null
        timeout_sec         = null
        healthy_threshold   = null
        unhealthy_threshold = null
        request_path        = "/"
        port                = 80
        host                = null
        logging             = null
      }

      log_config = {
        enable = true
        sample_rate = 1.0
      }

      groups = [
        {
          # Each node pool instance group should be added to the backend.
          group                        = module.mig.instance_group
          balancing_mode               = null
          capacity_scaler              = null
          description                  = null
          max_connections              = null
          max_connections_per_instance = null
          max_connections_per_endpoint = null
          max_rate                     = null
          max_rate_per_instance        = null
          max_rate_per_endpoint        = null
          max_utilization              = null
        },
      ]

      iap_config = {
        enable               = true
        oauth2_client_id     = google_iap_client.project_client.client_id
        oauth2_client_secret = google_iap_client.project_client.secret
      }
    }
  }
}
