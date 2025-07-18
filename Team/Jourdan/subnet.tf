# Subnets here
resource "google_compute_subnetwork" "hw_team_uscentral" {
  name                     = "hw_team_uscentral"
  ip_cidr_range            = "10.80.60.0/24"
  region                   = "us-west1"
  network                  = google_compute_network.hw_team_main.id 
  private_ip_google_access = true
}