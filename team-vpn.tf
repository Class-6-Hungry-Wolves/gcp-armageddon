resource "google_compute_vpn_gateway" "team_target_gateway" {
  name     = "team-vpn"
  network  = google_compute_network.hw_team_admin_main.id
  provider = google.hw-team
}

resource "google_compute_address" "team_vpn_static_ip" {
  name     = "team-vpn-static-ip"
  provider = google.hw-team
}

resource "google_compute_forwarding_rule" "team_fr_esp" {
  name        = "team-fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.team_vpn_static_ip.address
  target      = google_compute_vpn_gateway.team_target_gateway.id
  provider    = google.hw-team
}

resource "google_compute_forwarding_rule" "team_fr_udp500" {
  name        = "team-fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.team_vpn_static_ip.address
  target      = google_compute_vpn_gateway.team_target_gateway.id
  provider    = google.hw-team
}

resource "google_compute_forwarding_rule" "team_fr_udp4500" {
  name        = "team-fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.team_vpn_static_ip.address
  target      = google_compute_vpn_gateway.team_target_gateway.id
  provider    = google.hw-team
}
