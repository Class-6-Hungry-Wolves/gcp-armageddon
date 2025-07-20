
resource "google_compute_network" "vito_vpc" {
  name                            = "vito-vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
  provider                        = google.hw-team
}

resource "google_compute_subnetwork" "vito_subnet" {
  name                     = "vito-subnet"
  ip_cidr_range            = "10.80.120.0/24"
  region                   = "us-east1"
  network                  = google_compute_network.vito_vpc.id
  private_ip_google_access = true
  provider                 = google.hw-team
}


resource "google_compute_firewall" "vito-allow-ssh" {
  name     = "vito-allow-ssh"
  network  = google_compute_network.vito_vpc.name
  provider = google.hw-team

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "vito-allow-icmp" {
  name     = "vito-allow-icmp"
  network  = google_compute_network.vito_vpc.name
  provider = google.hw-team

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_network_connectivity_spoke" "vito_spoke" {
  name        = "vito-spoke"
  location    = "global"
  description = "Spoke for vito vpc mesh"
  hub         = google_network_connectivity_hub.team-mesh.id
  provider    = google.hw-team
  linked_vpc_network {
    uri = google_compute_network.vito_vpc.self_link
  }
}
