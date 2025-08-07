resource "google_compute_network" "jourdan_vpc" {
  name                            = "jourdan-vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
  provider                        = google.nick
}

resource "google_compute_subnetwork" "jourdan_subnet" {
  name                     = "jourdan-subnet"
  ip_cidr_range            = "10.80.60.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.jourdan_vpc.id
  private_ip_google_access = true
  provider                 = google.nick
}

resource "google_compute_firewall" "jourdan-allow-ssh" {
  name     = "jourdan-allow-ssh"
  network  = google_compute_network.jourdan_vpc.name
  provider = google.nick
  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "jourdan-allow-icmp" {
  name     = "jourdan-allow-icmp"
  network  = google_compute_network.jourdan_vpc.name
  provider = google.nick
  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_network_connectivity_spoke" "jourdan_spoke" {
  name        = "jourdan-spoke"
  location    = "global"
  description = "Spoke for jourdan vpc mesh"
  hub         = google_network_connectivity_hub.team_mesh.id
  provider    = google.nick
  linked_vpc_network {
    uri = google_compute_network.jourdan_vpc.self_link
  }
  depends_on = [google_network_connectivity_group.team_group]
}

resource "google_compute_vpn_gateway" "jourdan_target_gateway" {
  name     = "jourdan-vpn"
  network  = google_compute_network.jourdan_vpc.id
  provider = google.nick
  region   = "us-central1"
}

resource "google_compute_address" "jourdan_vpn_static_ip" {
  name       = "jourdan-vpn-static-ip"
  provider   = google.nick
  region     = "us-central1"
  depends_on = [google_compute_network.jourdan_vpc]
}

resource "google_compute_forwarding_rule" "jourdan_fr_esp" {
  name        = "jourdan-fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.jourdan_vpn_static_ip.address
  target      = google_compute_vpn_gateway.jourdan_target_gateway.id
  region      = "us-central1"
  provider    = google.nick
}

resource "google_compute_forwarding_rule" "jourdan_fr_udp500" {
  name        = "jourdan-fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.jourdan_vpn_static_ip.address
  target      = google_compute_vpn_gateway.jourdan_target_gateway.id
  region      = "us-central1"
  provider    = google.nick
}

resource "google_compute_forwarding_rule" "jourdan_fr_udp4500" {
  name        = "jourdan-fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.jourdan_vpn_static_ip.address
  target      = google_compute_vpn_gateway.jourdan_target_gateway.id
  region      = "us-central1"
  provider    = google.nick
}

resource "google_compute_vpn_tunnel" "jourdan_tunnel" {
  name          = "jourdan-tunnel"
  peer_ip       = google_compute_address.vito_balerica_vpn_static_ip.address
  shared_secret = var.jourdan_vpn_shared_secret
  provider      = google.nick

  target_vpn_gateway = google_compute_vpn_gateway.jourdan_target_gateway.id
  region             = "us-central1"

  local_traffic_selector  = ["10.80.60.0/24"] # jourdan's subnet
  remote_traffic_selector = ["10.40.20.0/24"] # Balerica's subnet

  depends_on = [
    google_compute_forwarding_rule.jourdan_fr_esp,
    google_compute_forwarding_rule.jourdan_fr_udp500,
    google_compute_forwarding_rule.jourdan_fr_udp4500,
  ]
}

resource "google_compute_route" "jourdan_to_balerica_route" {
  name       = "jourdan-to-balerica-route"
  network    = google_compute_network.jourdan_vpc.name
  dest_range = "10.40.20.0/24"
  priority   = 1000
  provider   = google.nick

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.jourdan_tunnel.id
}
