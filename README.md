# IBM Spectrum LSF / Symphony Cluster on IBM Virtual Private Cloud Generation 2 Template

An [IBM Cloud Schematics](https://cloud.ibm.com/docs/schematics?topic=schematics-about-schematics) template to deploy and launch an HPC (High Performance Computing) cluster Tech Preview, IBM Spectrum LSF Suite and IBM Spectrum Symphony is used in the Tech Preview.
Schematics uses [Terraform](https://www.terraform.io/) as the infrastructure as code engine. With this template, you can provision and manage infrastructure as a single unit.
See the [Terraform provider docs](https://ibm-cloud.github.io/tf-ibm-docs/) for available resources for the IBM Cloud. **Note**: To create the resources that this template requests, your [IBM Cloud account](https://cloud.ibm.com/docs/iam?topic=iam-iammanidaccser#iammanidaccser) must have sufficient permissions.

**IMPORTANT**

Due to legal requirement, we cannot provide entitlement in this template, you should provide the URL of entitlement file in variable `entitlement_uri`.
For LSF, we use IBM Spectrum LSF Suite for Enterprise 10.2.0.8 (for Linux on x86-64 English).
For Symphony, we use IBM Spectrum Symphony 7.3.0.0 Evaluation Edition for Linux (64-bit).

## Brief Introduction
This template will deploy a HPC cluster with IBM Spectrum LSF or IBM Spectrum Symphony on IBM Virtual Private Cloud Generation 2.
Since this is just a Tech Preview, the configuration for the HPC cluster includes one master node only, you can specify how many compute nodes you want to deploy.

## Usage

### Create workspaces in IBM Cloud Schematics
1. Open [Schematics dashboard](https://cloud.ibm.com/schematics).
2. Click the button **Create a workspace**
3. Fill **Workspace name** with a name for the workspace 
4. Fill **GitHub or GitLab repository URL** with the URL of this template Git repository, say https://github.com/zybjcdl/spectrum-vpc-nextgen
5. Click button **Retrieve input variables**, fill values for variables.  Refrence following table for the detail information about variables.
6. Click button **Create** at right side of the page.

To create a HPC cluster with this workspace 
1. Click button **Generate plan**, check **Recent activity** list, wait the generation action complete, either **Plan generated** for success or **Failed to generate plan** for failed, click **View log** for detail log.
2. Click button **Apply plan**, check **Recent activity** list, wait the apply action complete, either **Plan applied** for success or **Failed to apply plan** for failed, click **View log** for detail log.

### Create an environment with Terraform Binary on your local workstation
1. Install the Terraform, to apply this template, you need to install the latest update of Terraform v0.11 (**Do not install v0.12**), you can download Terraform v0.11 package from [here](https://releases.hashicorp.com/terraform/)
2. Install the IBM Cloud Provider Plugin
- [Download the IBM Cloud provider plugin for Terraform](https://github.com/IBM-Bluemix/terraform-provider-ibm/releases).

- Unzip the release archive to extract the plugin binary (`terraform-provider-ibm_vX.Y.Z`).

- Move the binary into the Terraform [plugins directory](https://www.terraform.io/docs/configuration/providers.html#third-party-plugins) for the platform.
    - Linux/Unix/OS X: `~/.terraform.d/plugins`
    - Windows: `%APPDATA%\terraform.d\plugins`

To run this project locally:

1. Set values for variables in `terraform.tfvars`
2. Switch to the project folder in terminal, run `terraform init`.  Terraform performs initialization on the local environment.
2. Run `terraform plan`. Terraform performs a dry run to show what resources will be created.
3. Run `terraform apply`. Terraform creates and deploys resources to your environment.
    * You can see deployed infrastructure in [IBM Cloud Console](https://cloud.ibm.com/classic/devices).
4. Run `terraform destroy`. Terraform destroys all deployed resources in this environment.

### Variables
|Variable Name|Description|Default Value|
|-------------|-----------|-------------|
|ibmcloud_api_key|IBM Cloud API Key||
|master_host|Host name prefix for master node|master|
|Host name prefix for compute nodes|Host name prefix for compute nodes|compute|
|spectrum_product|IBM Spectrum product that to be installed, either symphony or lsf|symphony|
|cluster_name|the name of cluster|spectrum-cluster|
|zone|the vpc region info|
|ssh_key|The public key contents for the SSH keypair of remote console for access cluster node||
|entitlement_uri| the URI of IBM Spectrum Symphony entitlement file (this is meaningless for LSF)||
|cluster_admin_password|the password for administrator user **lsfadmin** for LSF, **egoadmin** for Symphony||
|num_computes|number of compute nodes|2|

