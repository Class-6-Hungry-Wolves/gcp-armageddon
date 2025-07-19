# Change this for nick
resource "google_compute_subnetwork" "hw_team_uswest" {
  name                     = "hw_team_uswest"
  ip_cidr_range            = "10.80.40.0/24"
  region                   = "us-west1"
  network                  = google_compute_network.hw_team_main.id 
  private_ip_google_access = true
}