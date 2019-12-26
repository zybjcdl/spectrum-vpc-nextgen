# (optional) Symphony / LSF cluster name
cluster_name = "spectrum-cluster"

# (required) Enter your IBM Cloud API Key
ibmcloud_api_key = ""

#(optional)	specify host name prefix for master node and compute nodes
master_host = "master"
compute_host = "compute"

# (optional) number of compute
num_computes = "1"

# (required) public ssh key for remote console that used to control the master/compute host
ssh_key = ""

# (optional) VPC Zone
zone = "us-south"

# (optional) Spectrum product need to be installed, either symphony or lsf
spectrum_product = "symphony"

# (optional) uri of scripts folder
# scripts_path_uri = "https://raw.githubusercontent.com/chenxpcn/spectrum-lsf-ibmcloud/master/scripts"
scripts_path_uri = "http://52.117.200.197/gen2_scripts_count"

# (optional) uri of installer package
installer_uri = ""

# (required) uri of entitlement file
entitlement_uri = ""

# (required) password for cluster administrator
cluster_admin_password = ""