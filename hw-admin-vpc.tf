resource "google_compute_network" "hw_team_admin_main" {
  name                            = "hw-team-admin-main"
  routing_mode                    = "REGIONAL"
  auto_create_subnetworks         = false
  mtu                             = 1460
  delete_default_routes_on_create = false
  provider                        = google.hw-team
}

resource "google_compute_subnetwork" "admin_subnet" {
  name                     = "admin-subnet"
  ip_cidr_range            = "10.80.20.0/24"
  region                   = "us-east4"
  network                  = google_compute_network.hw_team_admin_main.id
  private_ip_google_access = true
  provider                 = google.hw-team
}



resource "google_compute_firewall" "admin_allow_ssh" {
  name     = "admin-allow-ssh"
  network  = google_compute_network.hw_team_admin_main.name
  provider = google.hw-team

  allow {
    protocol = "tcp"
    ports    = ["22"]
  }

  source_ranges = ["0.0.0.0/0"]
}



resource "google_compute_firewall" "allow-icmp" {
  name     = "allow-icmp"
  network  = google_compute_network.hw_team_admin_main.name
  provider = google.hw-team
  allow {
    protocol = "icmp"
  }

  source_ranges = ["0.0.0.0/0"]
}

resource "google_network_connectivity_spoke" "team_spoke" {
  name        = "team_spoke"
  location    = "global"
  description = "Spoke for team vpc mesh"
  hub         = google_network_connectivity_hub.team-mesh.id
  provider    = google.hw-team
  linked_vpc_network {
    uri = google_compute_network.hw_team_admin_main.self_link
  }
}

resource "google_compute_vpn_tunnel" "team_tunnel" {
  name                    = "team-tunnel"
  peer_ip                 = google_compute_address.balerica_vpn_static_ip.address
  shared_secret           = var.vpn_shared_secret01
  project                 = "class65gcpproject-462600"
  target_vpn_gateway      = google_compute_vpn_gateway.team_target_gateway.id
  provider                = google.hw-team
  local_traffic_selector  = [google_compute_subnetwork.admin_subnet.ip_cidr_range]
  remote_traffic_selector = [google_compute_subnetwork.vito_balerica_inc_private.ip_cidr_range]

  depends_on = [
    google_compute_forwarding_rule.team_fr_esp,
    google_compute_forwarding_rule.team_fr_udp500,
    google_compute_forwarding_rule.team_fr_udp4500,
  ]
}

resource "google_compute_route" "team-to-balerica-route" {
  name       = "team-to-balerica-route"
  network    = google_compute_network.hw_team_admin_main.name 
  dest_range = "10.40.20.0/24"
  priority   = 1000
  project    = "class65gcpproject-462600"
  provider   = google.hw-team

  next_hop_vpn_tunnel = google_compute_vpn_tunnel.team_tunnel.id
}
