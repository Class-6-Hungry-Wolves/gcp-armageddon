# The team Network Connectivity Center for Vito's team
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
      "gcp-01-453500", 
      "hokuto-no-ken", 
      "class65gcpproject-462600"
    ]
  }
}