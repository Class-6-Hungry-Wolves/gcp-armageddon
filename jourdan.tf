resource "google_compute_network" "jourdan_vpc" {
  name                            = "jourdan-vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
  provider                        = google.hw-team
}

resource "google_compute_subnetwork" "jourdan_subnet" {
  name                     = "jourdan-subnet"
  ip_cidr_range            = "10.80.60.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.jourdan_vpc.id
  private_ip_google_access = true
  provider                 = google.hw-team
}


resource "google_compute_firewall" "jourdan-allow-ssh" {
  name     = "jourdan-allow-ssh"
  network  = google_compute_network.jourdan_vpc.name
  provider = google.hw-team

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "jourdan-allow-icmp" {
  name     = "jourdan-allow-icmp"
  network  = google_compute_network.jourdan_vpc.name
  provider = google.hw-team

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}
resource "google_network_connectivity_spoke" "jourdan_spoke" {
  name        = "jourdan-spoke"
  location    = "global"
  description = "Spoke for jourdan vpc mesh"
  hub         = google_network_connectivity_hub.team-mesh.id
  provider    = google.hw-team
  linked_vpc_network {
    uri = google_compute_network.jourdan_vpc.self_link
  }
}
