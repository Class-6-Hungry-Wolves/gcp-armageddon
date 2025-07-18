terraform {
  backend "gcs" {
    bucket      = "gcp-armageddon-bucket-for-tfstate71725"
    prefix      = "terraform/state"
    credentials = "class65gcpproject-462600-3dd7a46c5330.json"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}