resource "google_compute_network" "nick_vpc" {
  name                            = "nick-vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
  provider                        = google.nick
}

resource "google_compute_subnetwork" "nick_subnet" {
  name                     = "nick-subnet"
  ip_cidr_range            = "10.80.100.0/24"
  region                   = "europe-west2"
  network                  = google_compute_network.nick_vpc.id
  private_ip_google_access = true
  provider                 = google.nick
}


resource "google_compute_firewall" "nick-allow-ssh" {
  name     = "nick-allow-ssh"
  network  = google_compute_network.nick_vpc.name
  provider = google.nick

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_compute_firewall" "nick-allow-icmp" {
  name     = "nick-allow-icmp"
  network  = google_compute_network.nick_vpc.name
  provider = google.nick

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_network_connectivity_spoke" "nick_spoke" {
  name        = "nick-spoke"
  location    = "global"
  description = "Spoke for nick vpc mesh"
  hub         = google_network_connectivity_hub.team_mesh.id
  provider    = google.nick
  linked_vpc_network {
    uri = google_compute_network.nick_vpc.self_link
  }
}

resource "google_compute_vpn_gateway" "nick_target_gateway" {
  name     = "nick-vpn"
  network  = google_compute_network.nick_vpc.id
  provider = google.nick
  region   = "europe-west2"
}

resource "google_compute_address" "nick_vpn_static_ip" {
  name     = "nick-vpn-static-ip"
  provider = google.nick
  region   = "europe-west2"
}

resource "google_compute_forwarding_rule" "nick_fr_esp" {
  name        = "nick-fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.nick_vpn_static_ip.address
  target      = google_compute_vpn_gateway.nick_target_gateway.id
  region      = "europe-west2"
  provider    = google.nick
}

resource "google_compute_forwarding_rule" "nick_fr_udp500" {
  name        = "nick-fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.nick_vpn_static_ip.address
  target      = google_compute_vpn_gateway.nick_target_gateway.id
  region      = "europe-west2"
  provider    = google.nick
}

resource "google_compute_forwarding_rule" "nick_fr_udp4500" {
  name        = "nick-fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.nick_vpn_static_ip.address
  target      = google_compute_vpn_gateway.nick_target_gateway.id
  region      = "europe-west2"
  provider    = google.nick
}

resource "google_compute_vpn_tunnel" "nick_tunnel" {
  name          = "nick-tunnel"
  peer_ip       = google_compute_address.vito_balerica_vpn_static_ip.address
  shared_secret = var.nick_vpn_shared_secret
  provider      = google.nick

  target_vpn_gateway = google_compute_vpn_gateway.nick_target_gateway.id
  region             = "europe-west2"

  local_traffic_selector  = ["10.80.100.0/24"] # Nick's subnet
  remote_traffic_selector = ["10.40.20.0/24"]  # Balerica's subnet

  depends_on = [
    google_compute_forwarding_rule.nick_fr_esp,
    google_compute_forwarding_rule.nick_fr_udp500,
    google_compute_forwarding_rule.nick_fr_udp4500,
  ]
}

resource "google_compute_route" "nick_to_balerica_route" {
  name       = "nick-to-balerica-route"
  network    = google_compute_network.nick_vpc.name
  dest_range = "10.80.20.0/24"
  priority   = 1000
  provider   = google.nick

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.nick_tunnel.id
}
