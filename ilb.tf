# Commented out and only needed to use internal load balancers

# resource "google_compute_subnetwork" "proxy_only_subnet" {
#     provider = google-beta
# 
#     name          = "proxy-only-subnet"
#     ip_cidr_range = "10.129.0.0/23"
#     region        = var.region
#     purpose       = "INTERNAL_HTTPS_LOAD_BALANCER"
#     role          = "ACTIVE"
#     network       = google_compute_network.network.self_link
# }

# resource "google_compute_firewall" "fw-allow-proxies" {
#     name          = "fw-allow-proxies"
#     network       = google_compute_network.network.self_link
# 
#     allow {
#         protocol    = "tcp"
#         ports       = ["80", "8080", "443", "8443"]
#     }
# 
#     source_ranges = [
#         google_compute_subnetwork.proxy_only_subnet.ip_cidr_range,
#     ]
# }