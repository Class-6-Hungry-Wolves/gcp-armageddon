# Subnets here
resource "google_compute_subnetwork" "hw_team_asianortheast" {
  name                     = "hw_team_asianortheast"
  ip_cidr_range            = "10.80.80.0/24"
  region                   = "asia-northeast1"
  network                  = google_compute_network.hw_team_main.id 
  private_ip_google_access = true
}