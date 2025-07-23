# Xavier's Acct
provider "google" {
  project     = "gcp-01-453500"
  region      = "us-central1"
  credentials = "key.json"
  alias       = "hw-team"
}