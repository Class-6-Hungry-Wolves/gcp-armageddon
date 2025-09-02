# The team Network Connectivity Center for team connecting to Balerica
resource "google_network_connectivity_hub" "team_mesh" {
  name        = "team-mesh"
  description = "Team mesh for vpcs"
  provider    = google.nick
}


resource "google_network_connectivity_group" "team_group"  {
 hub         = google_network_connectivity_hub.team_mesh.id 
 name        = "default"
 description = "A sample hub group"
 provider    = google.nick
 auto_accept {
    auto_accept_projects = [
      "hokuto-no-ken", 
      "gcp-01-453500", 
      "class65gcpproject-462600"
    ]
  }
  depends_on = [google_network_connectivity_hub.team_mesh]
}