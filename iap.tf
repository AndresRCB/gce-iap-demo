# Note: Only internal org clients can be created via declarative tools. External clients must be manually created via the GCP console. This restriction is due to the existing APIs and not lack of support in this tool.

resource "google_iap_brand" "project_brand" {
  support_email     = var.support_email
  application_title = var.application_name
  project           = module.project.project_id
}

resource "google_iap_client" "project_client" {
  display_name =  var.client_display_name
  brand        =  google_iap_brand.project_brand.name
}