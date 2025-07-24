resource "google_project_iam_member" "xavier" {
  project  = "class65gcpproject-462600"
  for_each = var.sa-roles
  role     = each.value
  member   = "serviceAccount:terraform-service@gcp-01-453500.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "vito" {
  project  = "class65gcpproject-462600"
  for_each = var.sa-roles
  role     = each.value
  member   = "serviceAccount:terraform-service@hokuto-no-ken.iam.gserviceaccount.com"
}

resource "google_project_iam_binding" "project" {
  project  = "class65gcpproject-462600"
  for_each = var.sa-roles
  role     = each.value

  members = [
    "serviceAccount:terraform-service@gcp-01-453500.iam.gserviceaccount.com", "serviceAccount:terraform-service@hokuto-no-ken.iam.gserviceaccount.com"
  ]
}
