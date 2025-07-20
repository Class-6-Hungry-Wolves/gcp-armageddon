# Change this for nick


resource "google_compute_network" "nick_vpc" {
  name                            = "nick-vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
  provider                        = google.hw-team
}

resource "google_compute_subnetwork" "nick_subnet" {
  name                     = "nick-subnet"
  ip_cidr_range            = "10.80.100.0/24"
  region                   = "europe-west2"
  network                  = google_compute_network.nick_vpc.id
  private_ip_google_access = true
  provider                 = google.hw-team
}


resource "google_compute_firewall" "nick-allow-ssh" {
  name     = "nick-allow-ssh"
  network  = google_compute_network.nick_vpc.name
  provider = google.hw-team

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "nick-allow-icmp" {
  name     = "nick-allow-icmp"
  network  = google_compute_network.nick_vpc.name
  provider = google.hw-team

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_network_connectivity_spoke" "nick_spoke" {
  name        = "nick-spoke"
  location    = "global"
  description = "Spoke for nick vpc mesh"
  hub         = google_network_connectivity_hub.team-mesh.id
  provider    = google.hw-team
  linked_vpc_network {
    uri = google_compute_network.nick_vpc.self_link
  }
}
