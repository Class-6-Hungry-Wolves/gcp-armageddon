variable "nick_vpn_shared_secret" {}
variable "xavier_vpn_shared_secret" {}
variable "jourdan_vpn_shared_secret" {}
variable "joshua_vpn_shared_secret" {}


variable "sa-roles" {
  type = set(string)
  default = ["roles/storage.admin", "roles/artifactregistry.admin", "roles/networkconnectivity.hubAdmin"]
}