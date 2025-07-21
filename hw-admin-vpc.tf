resource "google_compute_network" "hw_team_admin_main" {
  name                            = "hw-team-admin-main"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
  provider                        = google.hw-team
}

resource "google_compute_subnetwork" "admin_subnet" {
  name                     = "admin-subnet"
  ip_cidr_range            = "10.80.20.0/24"
  region                   = "us-east4"
  network                  = google_compute_network.hw_team_admin_main.id 
  private_ip_google_access = true
  provider                 = google.hw-team
}



resource "google_compute_firewall" "admin_allow_ssh" {
  name     = "admin-allow-ssh"
  network  = google_compute_network.hw_team_admin_main.name
  provider = google.hw-team

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "allow-icmp" {
  name     = "allow-icmp"
  network  = google_compute_network.hw_team_admin_main.name
  provider = google.hw-team
  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_network_connectivity_spoke" "team_spoke"  {
  name = "team_spoke"
  location = "global"
  description = "Spoke for team vpc mesh"
  hub = google_network_connectivity_hub.team-mesh.id
  provider = google.hw-team
  linked_vpc_network {
    uri = google_compute_network.hw_team_admin_main.self_link
  }
}
