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


resource "google_compute_vpn_tunnel" "balerica_to_hw_team_admin_tunnel" {
  name                    = "balerica-to-hw-team-admin-tunnel"
  peer_ip                 = google_compute_address.team_vpn_static_ip.address
  shared_secret           = var.vpn_shared_secret01
  provider                = google.balerica
  local_traffic_selector  = [google_compute_subnetwork.vito_balerica_inc_private.ip_cidr_range]
  remote_traffic_selector = [google_compute_subnetwork.admin_subnet.ip_cidr_range]
  target_vpn_gateway      = google_compute_vpn_gateway.balerica_target_gateway.id

  depends_on = [
    google_compute_forwarding_rule.balerica_fr_esp,
    google_compute_forwarding_rule.balerica_fr_udp500,
    google_compute_forwarding_rule.balerica_fr_udp4500,
  ]
}

resource "google_compute_route" "balerica_to_team_route" {
  name                = "balerica-to-team-route"
  network             = google_compute_network.vito_balerica_inc_main.name
  dest_range          = "10.80.20.0/24"
  priority            = 1000
  provider            = google.balerica
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.balerica_to_hw_team_admin_tunnel.id
}


resource "google_compute_vpn_tunnel" "balerica_to_joshua_tunnel" {
  name                    = "joshua-tunnel"
  peer_ip                 = google_compute_address.joshua_vpn_static_ip.address
  shared_secret           = var.vpn_shared_secret02
  provider                = google.balerica
  local_traffic_selector  = [google_compute_subnetwork.vito_balerica_inc_private.ip_cidr_range]
  remote_traffic_selector = [google_compute_subnetwork.joshua_subnet.ip_cidr_range]
  target_vpn_gateway      = google_compute_vpn_gateway.balerica_target_gateway.id

  depends_on = [
    google_compute_forwarding_rule.balerica_fr_esp,
    google_compute_forwarding_rule.balerica_fr_udp500,
    google_compute_forwarding_rule.balerica_fr_udp4500,
  ]
}

resource "google_compute_route" "balerica_to_joshua_route" {
  name                = "balerica-to-joshua-route"
  network             = google_compute_network.vito_balerica_inc_main.name
  dest_range          = "10.80.80.0/24"
  priority            = 1000
  provider            = google.balerica
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.balerica_to_joshua_tunnel.id
}


resource "google_compute_vpn_tunnel" "balerica_to_jourdan_tunnel" {
  name                    = "jourdan-tunnel"
  peer_ip                 = google_compute_address.jourdan_vpn_static_ip.address
  shared_secret           = var.vpn_shared_secret03
  provider                = google.balerica
  local_traffic_selector  = [google_compute_subnetwork.vito_balerica_inc_private.ip_cidr_range]
  remote_traffic_selector = [google_compute_subnetwork.jourdan_subnet.ip_cidr_range]
  target_vpn_gateway      = google_compute_vpn_gateway.balerica_target_gateway.id

  depends_on = [
    google_compute_forwarding_rule.balerica_fr_esp,
    google_compute_forwarding_rule.balerica_fr_udp500,
    google_compute_forwarding_rule.balerica_fr_udp4500,
  ]
}

resource "google_compute_route" "balerica_to_jourdan_route" {
  name                = "balerica-to-jourdan-route"
  network             = google_compute_network.vito_balerica_inc_main.name
  dest_range          = "10.80.60.0/24"
  priority            = 1000
  provider            = google.balerica
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.balerica_to_jourdan_tunnel.id
}

resource "google_compute_vpn_tunnel" "balerica_to_nick_tunnel" {
  name                    = "nick-tunnel"
  peer_ip                 = google_compute_address.nick_vpn_static_ip.address
  shared_secret           = var.vpn_shared_secret04
  provider                = google.balerica
  local_traffic_selector  = [google_compute_subnetwork.vito_balerica_inc_private.ip_cidr_range]
  remote_traffic_selector = [google_compute_subnetwork.nick_subnet.ip_cidr_range]
  target_vpn_gateway      = google_compute_vpn_gateway.balerica_target_gateway.id

  depends_on = [
    google_compute_forwarding_rule.balerica_fr_esp,
    google_compute_forwarding_rule.balerica_fr_udp500,
    google_compute_forwarding_rule.balerica_fr_udp4500,
  ]
}

resource "google_compute_route" "balerica_to_nick_route" {
  name                = "balerica-to-nick-route"
  network             = google_compute_network.vito_balerica_inc_main.name
  dest_range          = "10.80.100.0/24"
  priority            = 1000
  provider            = google.balerica
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.balerica_to_nick_tunnel.id
}

resource "google_compute_vpn_tunnel" "balerica_to_xavier_tunnel" {
  name                    = "xavier-tunnel"
  peer_ip                 = google_compute_address.xavier_vpn_static_ip.address
  shared_secret           = var.vpn_shared_secret05
  provider                = google.balerica
  local_traffic_selector  = [google_compute_subnetwork.vito_balerica_inc_private.ip_cidr_range]
  remote_traffic_selector = [google_compute_subnetwork.xavier_subnet.ip_cidr_range]
  target_vpn_gateway      = google_compute_vpn_gateway.balerica_target_gateway.id

  depends_on = [
    google_compute_forwarding_rule.balerica_fr_esp,
    google_compute_forwarding_rule.balerica_fr_udp500,
    google_compute_forwarding_rule.balerica_fr_udp4500,
  ]
}

resource "google_compute_route" "balerica_to_xavier_route" {
  name                = "balerica-to-xavier-route"
  network             = google_compute_network.vito_balerica_inc_main.name
  dest_range          = "10.80.40.0/24"
  priority            = 1000
  provider            = google.balerica
  next_hop_vpn_tunnel = google_compute_vpn_tunnel.balerica_to_xavier_tunnel.id
}