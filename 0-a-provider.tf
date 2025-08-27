# THIS HAS TO CHANGE FOR ALL OF US
# Account 1 provider
# Vito
provider "google" {
  project     = "hokuto-no-ken"
  region      = "southamerica-east1"
  credentials = "hokuto-no-ken-23c5316b965a.json"
  alias       = "vito"
}

# Account 2 provider
# Xavier
provider "google" {
  project     = "gcp-01-453500"
  region      = "us-west1"
  credentials = "key.json"
  alias       = "xavier"
}

# Account 3 provider
# Nick
provider "google" {
  project     = "class65gcpproject-462600"
  region      = "europe-west2"
  credentials = "class65gcpproject-462600-3dd7a46c5330.json"
  alias       = "nick"
}

