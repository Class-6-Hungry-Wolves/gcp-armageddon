# Vito Balerica Admin


resource "google_compute_network" "vito_balerica_inc_main" {
  name                            = "vito-balerica-inc-main"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
  provider                        = google.balerica
}


resource "google_compute_subnetwork" "vito_balerica_inc_private" {
  name                     = "balerica-inc-private"
  ip_cidr_range            = "10.40.20.0/24"
  region                   = "southamerica-east1"
  network                  = google_compute_network.vito_balerica_inc_main.id 
  private_ip_google_access = true
  provider                 = google.balerica
}


resource "google_compute_firewall" "hq-allow-ssh" {
  name     = "hq-allow-ssh"
  network  = google_compute_network.vito_balerica_inc_main.name 
  provider = google.balerica

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "hq-allow-icmp" {
  name     = "hq-allow-icmp"
  network  = google_compute_network.vito_balerica_inc_main.name  
  provider = google.balerica

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}