
resource "google_compute_network" "xavier_vpc" {
  name                            = "xavier_vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "xavier_subnet" {
  name                     = "xavier_subnet"
  ip_cidr_range            = "10.80.40.0/24"
  region                   = "us-west1"
  network                  = google_compute_network.xavier_subnet.id 
  private_ip_google_access = true
}


resource "google_compute_firewall" "xavier-allow-ssh" {
  name    = "xavier-allow-ssh"
  network = google_compute_network.xavier_vpc.name 

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "xavier-allow-icmp" {
  name    = "xavier-allow-icmp"
  network = google_compute_network.xavier_vpc.name 

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_network_connectivity_spoke" "xavier_spoke"  {
  name = "xavier_spoke"
  location = "global"
  description = "Spoke for xavier vpc mesh"
  hub = google_network_connectivity_hub.team-mesh.id
  linked_vpc_network {
    uri = google_compute_network.xavier_vpc.self_link
  }
}