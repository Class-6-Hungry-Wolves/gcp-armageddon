
resource "google_compute_network" "xavier_vpc" {
  name                            = "xavier-vpc"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
  provider                        = google.hw-team
}

resource "google_compute_subnetwork" "xavier_subnet" {
  name                     = "xavier-subnet"
  ip_cidr_range            = "10.80.40.0/24"
  region                   = "us-west1"
  network                  = google_compute_network.xavier_vpc.id
  private_ip_google_access = true
  provider                 = google.hw-team
}


resource "google_compute_firewall" "xavier-allow-ssh" {
  name     = "xavier-allow-ssh"
  network  = google_compute_network.xavier_vpc.name
  provider = google.hw-team

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "xavier-allow-icmp" {
  name     = "xavier-allow-icmp"
  network  = google_compute_network.xavier_vpc.name
  provider = google.hw-team

  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_network_connectivity_spoke" "xavier_spoke" {
  name        = "xavier-spoke"
  location    = "global"
  description = "Spoke for xavier vpc mesh"
  hub         = google_network_connectivity_hub.team-mesh.id
  provider    = google.hw-team
  linked_vpc_network {
    uri = google_compute_network.xavier_vpc.self_link
  }
}



resource "google_compute_vpn_gateway" "xavier_target_gateway" {
  name     = "xavier-vpn"
  network  = google_compute_network.xavier_vpc.id
  provider = google.hw-team
}

resource "google_compute_address" "xavier_vpn_static_ip" {
  name     = "xavier-vpn-static-ip"
  provider = google.hw-team
}

resource "google_compute_forwarding_rule" "xavier_fr_esp" {
  name        = "xavier-fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.xavier_vpn_static_ip.address
  target      = google_compute_vpn_gateway.xavier_target_gateway.id
  provider    = google.hw-team
}

resource "google_compute_forwarding_rule" "xavier_fr_udp500" {
  name        = "xavier-fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.xavier_vpn_static_ip.address
  target      = google_compute_vpn_gateway.xavier_target_gateway.id
  provider    = google.hw-team
}

resource "google_compute_forwarding_rule" "xavier_fr_udp4500" {
  name        = "xavier-fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.xavier_vpn_static_ip.address
  target      = google_compute_vpn_gateway.xavier_target_gateway.id
  provider    = google.hw-team
}




resource "google_compute_vpn_tunnel" "xavier_tunnel" {
  name                    = "xavier-tunnel"
  peer_ip                 = google_compute_address.balerica_vpn_static_ip.address
  shared_secret           = var.vpn_shared_secret05
  target_vpn_gateway      = google_compute_vpn_gateway.xavier_target_gateway.id
  provider                = google.hw-team
  local_traffic_selector  = [google_compute_subnetwork.xavier_subnet.ip_cidr_range]
  remote_traffic_selector = [google_compute_subnetwork.vito_balerica_inc_private.ip_cidr_range]

  depends_on = [
    google_compute_forwarding_rule.xavier_fr_esp,
    google_compute_forwarding_rule.xavier_fr_udp500,
    google_compute_forwarding_rule.xavier_fr_udp4500,
  ]
}

resource "google_compute_route" "xavier_to_balerica_route" {
  name       = "xavier-to-balerica-route"
  network    = google_compute_network.xavier_vpc.name 
  dest_range = "10.40.20.0/24"
  priority   = 1000
  provider   = google.hw-team

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.xavier_tunnel.id
}
