# Note: Only internal org clients can be created via declarative tools. External clients must be manually created via the GCP console. This restriction is due to the existing APIs and not lack of support in this tool.

resource "google_iap_brand" "project_brand" {
  support_email     = var.support_email
  application_title = "Cloud IAP protected Application"
  project           = module.project.project_id
}

resource "google_iap_client" "project_client" {
  display_name = "Test Client"
  brand        =  google_iap_brand.project_brand.name
}