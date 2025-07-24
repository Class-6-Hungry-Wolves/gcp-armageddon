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

#   source_ranges = ["0.0.0.0/0"]
# }

resource "google_compute_vpn_gateway" "vito_balerica_target_gateway" {
  name     = "vito-balerica-vpn"
  network  = google_compute_network.vito_balerica_inc_main.id
  region   = "us-east1"
  provider = google.vito
}

resource "google_compute_address" "vito_balerica_vpn_static_ip" {
  name     = "vito-balerica-vpn-static-ip"
  region   = "us-east1"
  provider = google.vito
}

resource "google_compute_forwarding_rule" "vito_balerica_fr_esp" {
  name        = "vito-balerica-fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.vito_balerica_vpn_static_ip.address
  target      = google_compute_vpn_gateway.vito_balerica_target_gateway.id
  region      = "us-east1"
  provider    = google.vito
}

resource "google_compute_forwarding_rule" "vito_balerica_fr_udp500" {
  name        = "vito-balerica-fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.vito_balerica_vpn_static_ip.address
  target      = google_compute_vpn_gateway.vito_balerica_target_gateway.id
  region      = "us-east1"
  provider    = google.vito
}

resource "google_compute_forwarding_rule" "vito_balerica_fr_udp4500" {
  name        = "vito-balerica-fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.vito_balerica_vpn_static_ip.address
  target      = google_compute_vpn_gateway.vito_balerica_target_gateway.id
  region      = "us-east1"
  provider    = google.vito
}

resource "google_compute_vpn_tunnel" "vito_balerica_to_nick_tunnel" {
  name          = "vito-balerica-to-nick-tunnel"
  peer_ip       = google_compute_address.nick_vpn_static_ip.address 
  shared_secret = var.nick_vpn_shared_secret
  region        = "us-east1"
  provider      = google.vito

  target_vpn_gateway = google_compute_vpn_gateway.vito_balerica_target_gateway.id

  local_traffic_selector  = ["10.40.20.0/24"] # Balerica subnet
  remote_traffic_selector = ["10.80.100.0/24"] # Nick subnet

  depends_on = [
    google_compute_forwarding_rule.vito_balerica_fr_esp,
    google_compute_forwarding_rule.vito_balerica_fr_udp500,
    google_compute_forwarding_rule.vito_balerica_fr_udp4500,
  ]
}

resource "google_compute_route" "vito_balerica_to_nick_route" {
  name       = "vito-balerica-to-nick-route"
  network    = google_compute_network.vito_balerica_inc_main.name
  dest_range = "10.80.100.0/24" # Nick's subnet
  priority   = 1000
  provider   = google.vito

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.vito_balerica_to_nick_tunnel.id
}

resource "google_compute_vpn_tunnel" "vito_balerica_to_xavier_tunnel" {
  name          = "vito-balerica-to-xavier-tunnel"
  peer_ip       = google_compute_address.xavier_vpn_static_ip.address 
  shared_secret = var.xavier_vpn_shared_secret
  region        = "us-east1"
  provider      = google.vito

  target_vpn_gateway = google_compute_vpn_gateway.vito_balerica_target_gateway.id

  local_traffic_selector  = ["10.40.20.0/24"] # Balerica subnet
  remote_traffic_selector = ["10.80.40.0/24"] # xavier subnet

  depends_on = [
    google_compute_forwarding_rule.vito_balerica_fr_esp,
    google_compute_forwarding_rule.vito_balerica_fr_udp500,
    google_compute_forwarding_rule.vito_balerica_fr_udp4500,
  ]
}

resource "google_compute_route" "vito_balerica_to_xavier_route" {
  name       = "vito-balerica-to-xavier-route"
  network    = google_compute_network.vito_balerica_inc_main.name
  dest_range = "10.80.40.0/24" # xavier's subnet
  priority   = 1000
  provider   = google.vito

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.vito_balerica_to_xavier_tunnel.id
}

resource "google_compute_vpn_tunnel" "vito_balerica_to_jourdan_tunnel" {
  name          = "vito-balerica-to-jourdan-tunnel"
  peer_ip       = google_compute_address.jourdan_vpn_static_ip.address 
  shared_secret = var.jourdan_vpn_shared_secret
  region        = "us-east1"
  provider      = google.vito

  target_vpn_gateway = google_compute_vpn_gateway.vito_balerica_target_gateway.id

  local_traffic_selector  = ["10.40.20.0/24"] # Balerica subnet
  remote_traffic_selector = ["10.80.60.0/24"] # jourdan subnet

  depends_on = [
    google_compute_forwarding_rule.vito_balerica_fr_esp,
    google_compute_forwarding_rule.vito_balerica_fr_udp500,
    google_compute_forwarding_rule.vito_balerica_fr_udp4500,
  ]
}

resource "google_compute_route" "vito_balerica_to_jourdan_route" {
  name       = "vito-balerica-to-jourdan-route"
  network    = google_compute_network.vito_balerica_inc_main.name
  dest_range = "10.80.60.0/24" # jourdan's subnet
  priority   = 1000
  provider   = google.vito

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.vito_balerica_to_jourdan_tunnel.id
}

resource "google_compute_vpn_tunnel" "vito_balerica_to_joshua_tunnel" {
  name          = "vito-balerica-to-joshua-tunnel"
  peer_ip       = google_compute_address.joshua_vpn_static_ip.address 
  shared_secret = var.joshua_vpn_shared_secret
  region        = "us-east1"
  provider      = google.vito

  target_vpn_gateway = google_compute_vpn_gateway.vito_balerica_target_gateway.id

  local_traffic_selector  = ["10.40.20.0/24"] # Balerica subnet
  remote_traffic_selector = ["10.80.80.0/24"] # joshua subnet

  depends_on = [
    google_compute_forwarding_rule.vito_balerica_fr_esp,
    google_compute_forwarding_rule.vito_balerica_fr_udp500,
    google_compute_forwarding_rule.vito_balerica_fr_udp4500,
  ]
}

resource "google_compute_route" "vito_balerica_to_joshua_route" {
  name       = "vito-balerica-to-joshua-route"
  network    = google_compute_network.vito_balerica_inc_main.name
  dest_range = "10.80.80.0/24" # joshua's subnet
  priority   = 1000
  provider   = google.vito

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.vito_balerica_to_joshua_tunnel.id
}