## TODO: NEED INSTANCE GROUP INSTEAD
# output "instance_connect_command" {
#   value       = "gcloud compute ssh --project=${var.project_id} --zone=${google_compute_instance.backend_instance.zone} ${google_compute_instance.backend_instance.name}"
#   description = "Command to connect to instance via SSH"
# }

output "org_id" {
    value = var.org_id
    description = "Organization ID for the demo project"
}

output "project_id" {
    value = var.project_id
    description = "Unique project ID for the demo project"
}

output "folder_id" {
    value = var.folder_id
    description = "Folder ID for the demo project"
}

output "region" {
    value = var.region
    description = "GCP region with demo resources"
}

output "network_name" {
    value = var.network_name
    description = "Name of the network that will be created for the demo"
}

output "subnet_name" {
    value = var.subnet_name
    description = "Name of the subnet that will be created for the demo backend instance"
}

output "subnet_cidr_range" {
    value = google_compute_subnetwork.subnetwork.ip_cidr_range
    description = "Node CIDR range for demo cluster"
}

output "load_balancer_ip" {
    value = module.gce-lb-http.external_ip
    description = "The IPv4 address for the global load balancer"
}
