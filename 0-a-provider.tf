# THIS HAS TO CHANGE FOR ALL OF US
# Account 1 provider
# Vito

# This will be the provider that is representing a Balerica Inc admin Vito and the provider that joshua.tf will be using
provider "google" {
  project     = "hokuto-no-ken"
  region      = "southamerica-east1"
  credentials = "hokuto-no-ken-23c5316b965a.json"
  alias       = "vito"
}

# Account 2 provider
# Xavier

# This will be the provider for xavier.tf and yahshua.tf
provider "google" {
  project     = "gcp-01-453500"
  region      = "us-west1"
  credentials = "key.json"
  alias       = "xavier"
}

# Account 3 provider
# Nick

# This will be the provider for nick.tf and jourdan.tf. This will also be the provider that the team-ncc.tf is using.
provider "google" {
  project     = "class65gcpproject-462600"
  region      = "europe-west2"
  credentials = "class65gcpproject-462600-3dd7a46c5330.json"
  alias       = "nick"
}

