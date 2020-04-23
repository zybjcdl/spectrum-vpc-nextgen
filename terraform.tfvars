# (optional) Symphony / LSF cluster name
cluster_name = "spectrum-cluster"

# (required) Enter your IBM Cloud API Key
ibmcloud_api_key = ""

#(optional)	specify host name prefix for master node and compute nodes
master_host = "master"
compute_host = "compute"

# (optional) number of compute nodes
num_computes = "2"

# (required) public ssh key for remote console that used to control the master/compute host
ssh_key = ""

# (optional) VPC Zone
zone = "us-south"

# (optional) Spectrum product need to be installed, either symphony or lsf
spectrum_product = "symphony"

# (required) uri of entitlement file
entitlement_uri = ""

# (optional) uri of scripts folder
scripts_path_uri = "https://raw.githubusercontent.com/zybjcdl/spectrum-vpc-nextgen/rel-0.2/scripts"

# (required) password for cluster administrator
cluster_admin_password = ""

# (required) userid for installation package download
download_userid = ""

# (required) password for installation package download
download_password = ""