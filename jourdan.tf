resource "google_compute_network" "jourdan_vpc" {
  name                            = "jourdan-vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
  provider                        = google.hw-team
}

resource "google_compute_subnetwork" "jourdan_subnet" {
  name                     = "jourdan-subnet"
  ip_cidr_range            = "10.80.60.0/24"
  region                   = "us-central1"
  network                  = google_compute_network.jourdan_vpc.id
  private_ip_google_access = true
  provider                 = google.hw-team
}


resource "google_compute_firewall" "jourdan-allow-ssh" {
  name     = "jourdan-allow-ssh"
  network  = google_compute_network.jourdan_vpc.name
  provider = google.hw-team

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "jourdan-allow-icmp" {
  name     = "jourdan-allow-icmp"
  network  = google_compute_network.jourdan_vpc.name
  provider = google.hw-team

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}
resource "google_network_connectivity_spoke" "jourdan_spoke" {
  name        = "jourdan-spoke"
  location    = "global"
  description = "Spoke for jourdan vpc mesh"
  hub         = google_network_connectivity_hub.team-mesh.id
  provider    = google.hw-team
  linked_vpc_network {
    uri = google_compute_network.jourdan_vpc.self_link
  }
}

resource "google_compute_vpn_gateway" "jourdan_target_gateway" {
  name     = "jourdan-vpn"
  network  = google_compute_network.jourdan_vpc.id
  provider = google.hw-team
}

resource "google_compute_address" "jourdan_vpn_static_ip" {
  name     = "jourdan-vpn-static-ip"
  provider = google.hw-team
}

resource "google_compute_forwarding_rule" "jourdan_fr_esp" {
  name        = "jourdan-fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.jourdan_vpn_static_ip.address
  target      = google_compute_vpn_gateway.jourdan_target_gateway.id
  provider    = google.hw-team
}

resource "google_compute_forwarding_rule" "jourdan_fr_udp500" {
  name        = "jourdan-fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.jourdan_vpn_static_ip.address
  target      = google_compute_vpn_gateway.jourdan_target_gateway.id
  provider    = google.hw-team
}

resource "google_compute_forwarding_rule" "jourdan_fr_udp4500" {
  name        = "jourdan-fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.jourdan_vpn_static_ip.address
  target      = google_compute_vpn_gateway.jourdan_target_gateway.id
  provider    = google.hw-team
}


resource "google_compute_vpn_tunnel" "jourdan_tunnel" {
  name                    = "jourdan-tunnel"
  peer_ip                 = google_compute_address.balerica_vpn_static_ip.address
  shared_secret           = var.vpn_shared_secret03
  project                 = "class65gcpproject-462600"
  target_vpn_gateway      = google_compute_vpn_gateway.jourdan_target_gateway.id
  provider                = google.hw-team
  local_traffic_selector  = [google_compute_subnetwork.jourdan_subnet.ip_cidr_range]
  remote_traffic_selector = [google_compute_subnetwork.vito_balerica_inc_private.ip_cidr_range]

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
  project    = "class65gcpproject-462600"
  provider   = google.hw-team

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.jourdan_tunnel.id
}
