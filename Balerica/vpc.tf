resource "google_compute_network" "balerica_inc_main" {
  name                            = "balerica_inc_main"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
}


resource "google_compute_subnetwork" "balerica_inc_private" {
  name                     = "balerica_inc_private"
  ip_cidr_range            = "10.80.20.0/24"
  region                   = "south-americaeast1"
  network                  = google_compute_network.balerica_inc_main.id 
  private_ip_google_access = true
}


resource "google_compute_firewall" "allow-ssh" {
  name    = "allow-ssh"
  network = google_compute_network.balerica_inc_main.name 

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "allow-icmp" {
  name    = "allow-icmp"
  network = google_compute_network.balerica_inc_main.name 

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}