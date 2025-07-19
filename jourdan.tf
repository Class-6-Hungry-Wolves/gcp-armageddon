resource "google_compute_network" "jourdan_vpc" {
  name                            = "jourdan_vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
}

resource "google_compute_subnetwork" "jourdan_subnet" {
  name                     = "jourdan_subnet"
  ip_cidr_range            = "10.80.60.0/24"
  region                   = "us-central-west1"
  network                  = google_compute_network.jourdan_subnet.id 
  private_ip_google_access = true
}


resource "google_compute_firewall" "jourdan-allow-ssh" {
  name    = "jourdan-allow-ssh"
  network = google_compute_network.jourdan_vpc.name 

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "jourdan-allow-icmp" {
  name    = "jourdan-allow-icmp"
  network = google_compute_network.jourdan_vpc.name 

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}
resource "google_network_connectivity_spoke" "jourdan_spoke"  {
  name = "jourdan_spoke"
  location = "global"
  description = "Spoke for jourdan vpc mesh"
  hub = google_network_connectivity_hub.team-mesh.id
  linked_vpc_network {
    uri = google_compute_network.jourdan_vpc.self_link
  }
}