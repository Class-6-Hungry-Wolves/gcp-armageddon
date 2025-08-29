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

gcloud auth activate-service-account [SERVICE_ACCOUNT_EMAIL] --key-file=[KEY_FILE_PATH]

```





# Provider, Backend, and IAM

In file 0-a we have set up the providers for the different accounts we will be creating resources in.

For the current configuration you must have a MINIMUM of 3 accounts to be set as providers

This is how the provider needs to be set up
```terraform 

provider "google" {
  project     = "project-name"
  region      = "region-name"
  credentials = "gcp-terraform-sa-credentials.json"
  alias       = "alias-name-here"
}

```





