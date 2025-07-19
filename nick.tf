# Change this for nick


resource "google_compute_network" "nick_vpc" {
  name                            = "nick_vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "nick_subnet" {
  name                     = "nick_subnet"
  ip_cidr_range            = "10.80.100.0/24"
  region                   = "asia-northeast1"
  network                  = google_compute_network.nick_subnet.id 
  private_ip_google_access = true
}


resource "google_compute_firewall" "nick-allow-ssh" {
  name    = "nick-allow-ssh"
  network = google_compute_network.nick_vpc.name 

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "nick-allow-icmp" {
  name    = "nick-allow-icmp"
  network = google_compute_network.nick_vpc.name 

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}