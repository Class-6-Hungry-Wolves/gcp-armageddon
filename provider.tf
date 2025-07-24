# THIS HAS TO CHANGE FOR ALL OF US
# Team 1 provider
# Nick
provider "google" {
  project     = "class65gcpproject-462600"
  region      = "europe-west2"
  credentials = "class65gcpproject-462600-3dd7a46c5330.json"
  alias       = "nick"
}

# Team 2 provider
# Xavier
provider "google" {
  project     = "gcp-01-453500"
  region      = "us-west1"
  credentials = "key.json"
  alias       = "xavier"
}

# Team 3 provider
# Jourdan
# provider "google" {
#   project     = "class65gcpproject-462600"
#   region      = "london"
#   credentials = "class65gcpproject-462600-3dd7a46c5330.json"
#   alias       = "jourdan"
# }

# # Team 4 provider
# # Joshua
# provider "google" {
#   project     = "class65gcpproject-462600"
#   region      = "london"
#   credentials = "class65gcpproject-462600-3dd7a46c5330.json"
#   alias       = "joshua"
# }


# Balerica provider
# Vito
provider "google" {
  project     = "hokuto-no-ken"
  region      = "southamerica-east1"
  credentials = "hokuto-no-ken-23c5316b965a.json"
  alias       = "vito"
}