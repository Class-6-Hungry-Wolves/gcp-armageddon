
resource "google_compute_network" "vito_vpc" {
  name                            = "vito_vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "vito_subnet" {
  name                     = "vito_subnet"
  ip_cidr_range            = "10.80.120.0/24"
  region                   = "us-east1"
  network                  = google_compute_network.vito_subnet.id 
  private_ip_google_access = true
}


resource "google_compute_firewall" "vito-allow-ssh" {
  name    = "vito-allow-ssh"
  network = google_compute_network.vito_vpc.name 

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "vito-allow-icmp" {
  name    = "vito-allow-icmp"
  network = google_compute_network.vito_vpc.name 

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}