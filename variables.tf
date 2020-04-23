# variables supplied from terraform.tfvars

############################################################
# for provider.tf

variable "ibmcloud_api_key" {
  type = "string"
  description = "IBM Cloud API Key"
}

############################################################

variable ssh_key {
  type = "string"
  description = "Public SSH key of remote console for control"
}

variable zone {
  type = "string"
  default = "us-south"
  description = "VPC Zone"
}

variable master_host {
  type = "string"
  default = "master"
  description = "Host name prefix for master node"
}

variable compute_host {
  type = "string"
  default = "compute"
  description = "Host name prefix for compute nodes"
}

# for main.tf
variable "spectrum_product" {
  type = "string"
  description = "Spectrum product need to be installed, either symphony or lsf"
  default = "symphony"
}

variable "cluster_name" {
  type = "string"
  description = "Symphony / LSF cluster name"
  default = "spectrum-cluster"
}

variable "entitlement_uri" {
  type = "string"
  description = "URI of Symphony entitlement file"
}

variable "scripts_path_uri" {
  type = "string"
  description = "URI of scripts folder"
  default = "https://raw.githubusercontent.com/zybjcdl/spectrum-vpc-nextgen/rel-0.2/scripts"
}

variable "cluster_admin_password" {
  type = "string"
  description = "Password for cluster administrator"
}

variable "num_computes" {
  default = "2"
  description = "number of compute nodes"
}

variable "download_userid" {
  type = "string"
  description = "UserId for installation package download"
}

variable "download_password" {
  type = "string"
  description = "Password for installation package download"
}