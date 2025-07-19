resource "google_compute_network" "joshua_vpc" {
  name                            = "joshua_vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
}


resource "google_compute_subnetwork" "joshua_subnet" {
  name                     = "joshua_subnet"
  ip_cidr_range            = "10.80.80.0/24"
  region                   = "asia-northeast1"
  network                  = google_compute_network.joshua_subnet.id 
  private_ip_google_access = true
}

resource "google_compute_firewall" "joshua-allow-ssh" {
  name    = "joshua-allow-ssh"
  network = google_compute_network.joshua_vpc.name 

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "joshua-allow-icmp" {
  name    = "joshua-allow-icmp"
  network = google_compute_network.joshua_vpc.name 

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}
resource "google_network_connectivity_spoke" "joshua_spoke"  {
  name = "joshua_spoke"
  location = "global"
  description = "Spoke for joshua vpc mesh"
  hub = google_network_connectivity_hub.team-mesh.id
  linked_vpc_network {
    uri = google_compute_network.joshua_vpc.self_link
  }
}