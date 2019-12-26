# variables supplied from terraform.tfvars

############################################################
# for provider.tf

variable "ibmcloud_api_key" {
  type = "string"
  description = "ibmcloud api key"
}

############################################################

variable ssh_key {
  default = "test-key"
  description = "Public SSH key of remote console for control"
}

variable zone {
  default = "us-south"
  description = "Region info."
}

variable master_host {
  default = "symphony-master"
  description = "Name of master host"
}

variable compute_host {
  default = "symphony-compute"
  description = "Name of compute host"
}

# for main.tf
variable "spectrum_product" {
  type = "string"
  description = "symphony or lsf"
  default = "symphony"
}

variable "cluster_name" {
  type = "string"
  description = "Symphony / LSF cluster name"
  default = "spectrum-cluster"
}

variable "scripts_path_uri" {
  type = "string"
  description = "URI of scripts folder"
  default = "https://raw.githubusercontent.com/chenxpcn/spectrum-ibmcloud-basic/master/scripts"
}

variable "installer_uri" {
  type = "string"
  description = "URI of Symphony / LSF installer package"
}

variable "entitlement_uri" {
  type = "string"
  description = "URI of Symphony entitlement file"
  default="n/a"
}

variable "cluster_admin_password" {
  type = "string"
  description = "Password for cluster administrator"
}

variable "num_computes" {
  default = "2"
}