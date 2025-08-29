# gcp-armageddon-task-1

# Overview

This is our project for automating a portion of the Network Teams infrastructure as layed out in Task 1. This solution will enable the Network Team to connect to Balerica Inc. while also allowing the network team members to be easily connected with each other via the mesh topology network configuration.

We have leveraged several of GCP's cloud technologies such as their robust IAM and Admin services, the Network Connectivity Center, and the Classic VPN gateway using Terraform to automate the deployment of all of this infrastructure.


# Requirements 
The Network team is looking to automate a portion of their network infrastructure. 

In Terraform, build a classic (or HA) VPN connection that connects Balerica Inc. (GCP account) and your team (different GCP account). 

In addition, find a way to connect specific subnets from each team member to each other, creating a ring or similar topology between all participating group members and the VPN. 

Terraform code must also be accompanied by a network topology diagram, describing how team members are connected with each other, and how the team is connected with Balerica Inc. There must be a .tf file for each participating member's connections to Balerica Inc. and each other


# Diagram
![alt text](images/diagram.png)




## Prerequisites

Before you begin, ensure you have:

- [Terraform](https://www.terraform.io/downloads.html) v1.0+ installed
- [Google Cloud SDK](https://cloud.google.com/sdk/docs/install) installed and configured
- GCP Project with billing enabled
- Service Account with appropriate permissions
- `gcloud` CLI authenticated

### Required GCP APIs

Enable these APIs in your GCP projects:
```bash
gcloud services enable compute.googleapis.com
gcloud services enable cloudresourcemanager.googleapis.com
gcloud services enable iam.googleapis.com
gcloud services enable networkconnectivity.googleapis.com
gcloud services enable artifactregistry.googleapis.com
```

### Authentication Setup

```bash
# Authenticate with Google Cloud
gcloud auth login
gcloud config set project YOUR_PROJECT_ID

# Create terraform service account 
gcloud iam service-accounts create terraform-sa
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/editor"

# Add necessary iam roles
gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/storage.admin"

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/artifactregistry.admin"    

gcloud projects add-iam-policy-binding YOUR_PROJECT_ID \
    --member="serviceAccount:terraform-sa@YOUR_PROJECT_ID.iam.gserviceaccount.com" \
    --role="roles/networkconnectivity.hubAdmin"    

# Create json key for terraform service account
gcloud iam service-accounts keys create KEY_FILE_PATH --iam-account=SERVICE_ACCOUNT_EMAIL

# Activate terraform service account
gcloud auth activate-service-account [SERVICE_ACCOUNT_EMAIL] --key-file=[KEY_FILE_PATH]


# Create a Google Cloud Storage bucket to store terraform state file, utilizing best practices

gcloud storage buckets create gs://BUCKET_NAME --project=PROJECT_ID --default-storage-class=STORAGE_CLASS --location=BUCKET_LOCATION --uniform-bucket-level-access
--soft-delete-duration=RETENTION_DURATION

```

You will also need the json keys for your other team members terraform service accounts in order to authenticate
with the different providers.

For the current configuration you only need 3 json keys. However, depending on the size of your team and how you want to divvy up the accounts, you may need additional json keys.





# Provider

In file 0-a we have set up the providers for the different accounts we will be creating resources in.

For the current configuration you must have a MINIMUM of 3 accounts to be set as providers

You may add more providers as needed if you wish to have each team members account be its own provider

Ex. Jourdan.tf will have its own provider, Nick.tf will have its own provider etc.

This is how the providers need to be set up

```terraform 

provider "google" {
  project     = "project-name"
  region      = "region-name"
  credentials = "gcp-terraform-sa-credentials.json"
  alias       = "alias-name-here"
}

```

Account Number 1 will house all resources created in files 2 and 4
Account Number 2 will house all resources created in files 5a and 5b
Account Number 3 will house all resources created in files 3a, 3b, and 6

The providers must have an alias such that we are able to seperate terraform resources into different accounts and projects




# Backend

In file 0-b we have a backend storage bucket with a required provider version for hashicorp/google

Change the json credentials as needed to align with your terraform service account that you have set up in Authentication Setup

Change version to latest if need be

```terraform 
terraform {
  backend "gcs" {
    bucket      = "name-of-bucket"
    prefix      = "terraform/state"
    credentials = "gcp-terraform-sa-credentials.json"
  }

  required_providers {
    google = {
      source  = "hashicorp/google"
      version = "~> 6.0"
    }
  }
}
```



# IAM 

```terraform

resource "google_project_iam_member" "account-1-member" {
  project  = "project-name"
  for_each = var.sa-roles
  role     = each.value
  member   = "serviceAccount:terraform-sa@ACCOUNT_1_PROJECT_ID.iam.gserviceaccount.com"
}

resource "google_project_iam_member" "account-2-member" {
  project  = "project-name"
  for_each = var.sa-roles
  role     = each.value
  member   = "serviceAccount:terraform-sa@ACCOUNT_2_PROJECT_ID.iam.gserviceaccount.com"
}

resource "google_project_iam_binding" "project" {
  project  = "project-name"
  for_each = var.sa-roles
  role     = each.value

  members = [
    "serviceAccount:terraform-sa@ACCOUNT_1_PROJECT_ID.iam.gserviceaccount.com", 
    "serviceAccount:terraform-sa@ACCOUNT_2_PROJECT_ID.iam.gserviceaccount.com"
  ]
}

```







