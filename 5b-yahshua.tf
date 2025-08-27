resource "google_compute_network" "yahshua_vpc" {
  name                            = "yahshua-vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
  provider                        = google.xavier
}

resource "google_compute_subnetwork" "yahshua_subnet" {
  name                     = "yahshua-subnet"
  ip_cidr_range            = "10.80.120.0/24"
  region                   = "asia-east2"
  network                  = google_compute_network.yahshua_vpc.id
  private_ip_google_access = true
  provider                 = google.xavier
}

resource "google_compute_firewall" "yahshua-allow-ssh" {
  name     = "yahshua-allow-ssh"
  network  = google_compute_network.yahshua_vpc.name
  provider = google.xavier

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "yahshua-allow-icmp" {
  name     = "yahshua-allow-icmp"
  network  = google_compute_network.yahshua_vpc.name
  provider = google.xavier

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_network_connectivity_spoke" "yahshua_spoke" {
  name        = "yahshua-spoke"
  location    = "global"
  description = "Spoke for yahshua vpc mesh"
  hub         = google_network_connectivity_hub.team_mesh.id
  provider    = google.xavier
  linked_vpc_network {
    uri = google_compute_network.yahshua_vpc.self_link
  }
  depends_on = [google_network_connectivity_group.team_group]
}

resource "google_compute_vpn_gateway" "yahshua_target_gateway" {
  name     = "yahshua-vpn"
  network  = google_compute_network.yahshua_vpc.id
  provider = google.xavier
  region   = "asia-east2"
}

resource "google_compute_address" "yahshua_vpn_static_ip" {
  name       = "yahshua-vpn-static-ip"
  provider   = google.xavier
  region     = "asia-east2"
  depends_on = [google_compute_network.yahshua_vpc]
}

resource "google_compute_forwarding_rule" "yahshua_fr_esp" {
  name        = "yahshua-fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.yahshua_vpn_static_ip.address
  target      = google_compute_vpn_gateway.yahshua_target_gateway.id
  region      = "asia-east2"
  provider    = google.xavier
}

resource "google_compute_forwarding_rule" "yahshua_fr_udp500" {
  name        = "yahshua-fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.yahshua_vpn_static_ip.address
  target      = google_compute_vpn_gateway.yahshua_target_gateway.id
  region      = "asia-east2"
  provider    = google.xavier
}

resource "google_compute_forwarding_rule" "yahshua_fr_udp4500" {
  name        = "yahshua-fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.yahshua_vpn_static_ip.address
  target      = google_compute_vpn_gateway.yahshua_target_gateway.id
  region      = "asia-east2"
  provider    = google.xavier
}

resource "google_compute_vpn_tunnel" "yahshua_tunnel" {
  name          = "yahshua-tunnel"
  peer_ip       = google_compute_address.vito_balerica_vpn_static_ip.address
  shared_secret = var.yahshua_vpn_shared_secret
  provider      = google.xavier

  target_vpn_gateway = google_compute_vpn_gateway.yahshua_target_gateway.id
  region             = "asia-east2"

  local_traffic_selector  = ["10.80.120.0/24"] # yahshua's subnet
  remote_traffic_selector = ["10.40.20.0/24"]  # Balerica's subnet

  depends_on = [
    google_compute_forwarding_rule.yahshua_fr_esp,
    google_compute_forwarding_rule.yahshua_fr_udp500,
    google_compute_forwarding_rule.yahshua_fr_udp4500,
  ]
}

resource "google_compute_route" "yahshua_to_balerica_route" {
  name       = "yahshua-to-balerica-route"
  network    = google_compute_network.yahshua_vpc.name
  dest_range = "10.40.20.0/24"
  priority   = 1000
  provider   = google.xavier

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.yahshua_tunnel.id
}
