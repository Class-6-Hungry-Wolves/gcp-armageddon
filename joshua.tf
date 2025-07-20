resource "google_compute_network" "joshua_vpc" {
  name                            = "joshua-vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
  provider                        = google.hw-team
}


resource "google_compute_subnetwork" "joshua_subnet" {
  name                     = "joshua-subnet"
  ip_cidr_range            = "10.80.80.0/24"
  region                   = "asia-northeast1"
  network                  = google_compute_network.joshua_vpc.id
  private_ip_google_access = true
  provider                 = google.hw-team
}

resource "google_compute_firewall" "joshua-allow-ssh" {
  name     = "joshua-allow-ssh"
  network  = google_compute_network.joshua_vpc.name
  provider = google.hw-team

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "joshua-allow-icmp" {
  name     = "joshua-allow-icmp"
  network  = google_compute_network.joshua_vpc.name
  provider = google.hw-team

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}
resource "google_network_connectivity_spoke" "joshua_spoke" {
  name        = "joshua-spoke"
  location    = "global"
  description = "Spoke for joshua vpc mesh"
  hub         = google_network_connectivity_hub.team-mesh.id
  provider    = google.hw-team
  linked_vpc_network {
    uri = google_compute_network.joshua_vpc.self_link
  }
}
