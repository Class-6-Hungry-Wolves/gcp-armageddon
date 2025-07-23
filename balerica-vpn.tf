resource "google_compute_vpn_gateway" "balerica_target_gateway" {
  name     = "balercia-vpn"
  network  = google_compute_network.vito_balerica_inc_main.id
  provider = google.balerica
}

resource "google_compute_address" "balerica_vpn_static_ip" {
  name     = "balerica-vpn-static-ip"
  provider = google.balerica
}

resource "google_compute_forwarding_rule" "balerica_fr_esp" {
  name        = "balerica-fr-esp"
  ip_protocol = "ESP"
  ip_address  = google_compute_address.balerica_vpn_static_ip.address
  target      = google_compute_vpn_gateway.balerica_target_gateway.id
  provider    = google.balerica
}

resource "google_compute_forwarding_rule" "balerica_fr_udp500" {
  name        = "balerica-fr-udp500"
  ip_protocol = "UDP"
  port_range  = "500"
  ip_address  = google_compute_address.balerica_vpn_static_ip.address
  target      = google_compute_vpn_gateway.balerica_target_gateway.id
  provider    = google.balerica
}

resource "google_compute_forwarding_rule" "balerica_fr_udp4500" {
  name        = "balerica-fr-udp4500"
  ip_protocol = "UDP"
  port_range  = "4500"
  ip_address  = google_compute_address.balerica_vpn_static_ip.address
  target      = google_compute_vpn_gateway.balerica_target_gateway.id
  provider    = google.balerica
}
