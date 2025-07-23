resource "google_compute_network" "joshua_vpc" {
  name                            = "joshua-vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
  provider                        = google.joshua
}

resource "google_compute_subnetwork" "joshua_subnet" {
  name                     = "joshua-subnet"
  ip_cidr_range            = "10.80.80.0/24"
  region                   = "asia-northeast1"
  network                  = google_compute_network.joshua_vpc.id
  private_ip_google_access = true
  provider                 = google.joshua
}

resource "google_compute_firewall" "joshua-allow-ssh" {
  name     = "joshua-allow-ssh"
  network  = google_compute_network.joshua_vpc.name
  provider = google.joshua

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "joshua-allow-icmp" {
  name     = "joshua-allow-icmp"
  network  = google_compute_network.joshua_vpc.name
  provider = google.joshua

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
  provider    = google.joshua
  linked_vpc_network {
    uri = google_compute_network.joshua_vpc.self_link
  }
}

resource "google_compute_vpn_gateway" "joshua_target_gateway" {
  name    = "joshua-vpn"
  network = google_compute_network.joshua_vpc.id
  provider = google.joshua
  region = "asia-northeast1"
}

resource "google_compute_address" "joshua_vpn_static_ip" {
  name = "joshua-vpn-static-ip"
  provider = google.joshua
  region = "asia-northeast1"
}

resource "google_compute_forwarding_rule" "joshua_fr_esp" {
  name        = "joshua-fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.joshua_vpn_static_ip.address
  target      = google_compute_vpn_gateway.joshua_target_gateway.id
  provider = google.joshua
}

resource "google_compute_forwarding_rule" "joshua_fr_udp500" {
  name        = "joshua-fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.joshua_vpn_static_ip.address
  target      = google_compute_vpn_gateway.joshua_target_gateway.id
  provider = google.joshua
}

resource "google_compute_forwarding_rule" "joshua_fr_udp4500" {
  name        = "joshua-fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.joshua_vpn_static_ip.address
  target      = google_compute_vpn_gateway.joshua_target_gateway.id
  provider = google.joshua
}

resource "google_compute_vpn_tunnel" "joshua_tunnel" {
  name          = "joshua_tunnel"
  peer_ip       = google_compute_address.vito_balerica_vpn_static_ip.address
  shared_secret = var.joshua_vpn_shared_secret
  provider = google.joshua

  target_vpn_gateway = google_compute_vpn_gateway.joshua_target_gateway.id
  region                   = "asia-northeast1"

  local_traffic_selector  = ["10.80.80.0/24"]  # joshua's subnet
  remote_traffic_selector = ["10.40.20.0/24"]  # Balerica's subnet

  depends_on = [
    google_compute_forwarding_rule.joshua_fr_esp,
    google_compute_forwarding_rule.joshua_fr_udp500,
    google_compute_forwarding_rule.joshua_fr_udp4500,
  ]
}

resource "google_compute_route" "joshua_to_balerica_route" {
  name       = "joshua-to-balerica-route"
  network    = google_compute_network.joshua_vpc.name
  dest_range = "10.80.20.0/24"
  priority   = 1000
  provider = google.joshua

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.joshua_tunnel.id
}