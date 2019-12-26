locals {
    BASENAME = "${var.cluster_name}"
    ZONE     = "${var.zone}-1"
    product_name = "${var.spectrum_product == "symphony" ? "symphony" : "lsf"}"
    deployer_ssh_key_file_name = "deployer-ssh-key"
    master_ssh_key_file_name = "spectrum-master-ssh-key"
    compute_ssh_key_file_name = "spectrum-compute-ssh-key"
    param_list = [
                "${var.scripts_path_uri}",
                "${var.installer_uri}",
                "${var.entitlement_uri}",
                "${base64encode(var.cluster_admin_password)}",
                "${base64encode(var.ssh_key)}",
                "${var.cluster_name}",
                "${var.master_host}",
                "${ibm_is_instance.master.primary_network_interface.0.primary_ipv4_address}",
                "${var.num_computes}",
                "${join(",", ibm_is_instance.compute.*.name)}",
                "${join(",", ibm_is_instance.compute.*.primary_network_interface.0.primary_ipv4_address)}",
                ]
    parameters = "${join(" ", local.param_list)}"
   }



resource "null_resource" "create_deployer_ssh_key" {
  provisioner "local-exec" {
    command = "if [ ! -f '${local.deployer_ssh_key_file_name}' ]; then ssh-keygen -f ${local.deployer_ssh_key_file_name} -N '' -C 'deployer@deployer'; fi"
  }
}

data "local_file" "deployer_ssh_public_key" {
  filename = "${local.deployer_ssh_key_file_name}.pub"
  depends_on = ["null_resource.create_deployer_ssh_key"]
}

data "local_file" "deployer_ssh_private_key" {
  filename = "${local.deployer_ssh_key_file_name}"
  depends_on = ["null_resource.create_deployer_ssh_key"]
}

resource "ibm_is_ssh_key" "deployer_ssh_key" {
  name       = "deployer-ssh-key"
  public_key = "${data.local_file.deployer_ssh_public_key.content}"
  depends_on = ["null_resource.create_deployer_ssh_key"]
}

resource "null_resource" "create_master_ssh_key" {
  provisioner "local-exec" {
    command = "if [ ! -f '${local.master_ssh_key_file_name}' ]; then ssh-keygen -f ${local.master_ssh_key_file_name} -N '' -C 'master@master'; fi"
  }
}

resource "null_resource" "create_compute_ssh_key" {
  provisioner "local-exec" {
    command = "if [ ! -f '${local.compute_ssh_key_file_name}' ]; then ssh-keygen -f ${local.compute_ssh_key_file_name} -N '' -C 'compute@compute'; fi"
  }
}

resource ibm_is_vpc "vpc" {
  name = "${local.BASENAME}-vpc"
  classic_access = false

}

resource "ibm_is_public_gateway" "symphony_gateway" {
    name = "${local.BASENAME}-gateway"
    vpc = "${ibm_is_vpc.vpc.id}"
    zone = "${local.ZONE}"

    //User can configure timeouts
    timeouts {
        create = "90m"
    }
}


# allow all incoming network traffic on port 8443
resource "ibm_is_security_group_rule" "inbound_symphony" {
  group     = "${ibm_is_vpc.vpc.default_security_group}"
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp = {
    port_min = 8443
    port_max = 8443
  }

}

# allow all incoming network traffic on port 8443
resource "ibm_is_security_group_rule" "inbound_lsf" {
  group     = "${ibm_is_vpc.vpc.default_security_group}"
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp = {
    port_min = 8080
    port_max = 8080
  }

}


resource "ibm_is_security_group_rule" "ingress_ssh_all" {
  group     = "${ibm_is_vpc.vpc.default_security_group}"
  direction = "inbound"
  remote    = "0.0.0.0/0"

  tcp = {
    port_min = 22
    port_max = 22
  }
}

 resource "ibm_is_security_group_rule" "icmp_rule" {
    group = "${ibm_is_vpc.vpc.default_security_group}"
    direction = "inbound"
    remote = "0.0.0.0/0"
    icmp = {
        type = 8
    }
 }


resource ibm_is_subnet "subnet" {
  name = "${local.BASENAME}-subnet"
  vpc  = "${ibm_is_vpc.vpc.id}"
  zone = "${local.ZONE}"
  total_ipv4_address_count = 256
  public_gateway = "${ibm_is_public_gateway.symphony_gateway.id}"
}


resource ibm_is_ssh_key "ssh_key_id" {
  name       = "yan-ssh-key"
  public_key = "${var.ssh_key}"
}

data "ibm_is_image" "centos" {
    name = "ibm-centos-7-6-minimal-amd64-1"
}

# Create virtual servers with the SSH key.
resource "ibm_is_instance" "master" {
  name              = "${var.master_host}"
  vpc               = "${ibm_is_vpc.vpc.id}"
  zone              = "${local.ZONE}"
  keys              = ["${ibm_is_ssh_key.ssh_key_id.id}", "${ibm_is_ssh_key.deployer_ssh_key.id}"]
  image             = "${data.ibm_is_image.centos.id}"
  profile           = "mx2-4x32"
  primary_network_interface = {
    subnet          = "${ibm_is_subnet.subnet.id}"
    security_groups = ["${ibm_is_vpc.vpc.default_security_group}"]
  }
}


# Create virtual servers with the SSH key.
resource "ibm_is_instance" "compute" {
  name              = "${var.compute_host}-${count.index}"
  vpc               = "${ibm_is_vpc.vpc.id}"
  zone              = "${local.ZONE}"
  keys              = ["${ibm_is_ssh_key.ssh_key_id.id}", "${ibm_is_ssh_key.deployer_ssh_key.id}"]
  image             = "${data.ibm_is_image.centos.id}"
  profile           = "bx2-2x8"
  primary_network_interface = {
    subnet          = "${ibm_is_subnet.subnet.id}"
    security_groups = ["${ibm_is_vpc.vpc.default_security_group}"]
  }
  count = "${var.num_computes}"
}


# Create floating ip for master server
resource ibm_is_floating_ip "fipmaster" {
  name   = "${local.BASENAME}-fipmaster"
  target = "${ibm_is_instance.master.primary_network_interface.0.id}"
}

# Create floating ip for compute server
resource ibm_is_floating_ip "fipcompute" {
  name   = "${local.BASENAME}-fipcompute-${count.index}"
  count = "${var.num_computes}"
  target = "${element(ibm_is_instance.compute.*.primary_network_interface.0.id, count.index)}"
}


resource "null_resource" "pre-install-master" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${ibm_is_floating_ip.fipmaster.address}"
    private_key = "${data.local_file.deployer_ssh_private_key.content}"
  }

  provisioner "file" {
    source      = "${local.master_ssh_key_file_name}"
    destination = "/root/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = "${local.master_ssh_key_file_name}.pub"
    destination = "/root/.ssh/id_rsa.pub"
  }

  provisioner "file" {
    source      = "${local.compute_ssh_key_file_name}.pub"
    destination = "/root/.ssh/compute-host.pub"
  }

  provisioner "remote-exec" {
    inline  = [
      "mkdir -p /root/installer",
      "mkdir -p /root/logs",
      "wget -nv -nH -c --no-check-certificate -O /root/installer/downloads.sh ${var.scripts_path_uri}/${local.product_name}/downloads.sh",
      ". /root/installer/downloads.sh master ${local.parameters}",
      ". /root/installer/pre-install.sh master ${local.parameters}",
    ]
  }

  depends_on = ["null_resource.create_master_ssh_key","null_resource.create_compute_ssh_key","ibm_is_instance.master", "ibm_is_floating_ip.fipmaster"]
}

resource "null_resource" "pre-install-compute" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${element(ibm_is_floating_ip.fipcompute.*.address,count.index)}"
    private_key = "${data.local_file.deployer_ssh_private_key.content}"
  }
  count = "${var.num_computes}"
  provisioner "file" {
    source      = "${local.compute_ssh_key_file_name}"
    destination = "/root/.ssh/id_rsa"
  }

  provisioner "file" {
    source      = "${local.compute_ssh_key_file_name}.pub"
    destination = "/root/.ssh/id_rsa.pub"
  }

  provisioner "file" {
    source      = "${local.master_ssh_key_file_name}.pub"
    destination = "/root/.ssh/master-host.pub"
  }

  provisioner "remote-exec" {
    inline  = [
      "mkdir -p /root/installer",
      "mkdir -p /root/logs",
      "wget -nv -nH -c --no-check-certificate -O /root/installer/downloads.sh ${var.scripts_path_uri}/${local.product_name}/downloads.sh",
      ". /root/installer/downloads.sh compute ${local.parameters}",
      ". /root/installer/pre-install.sh compute ${local.parameters}",
    ]
  }
  depends_on = ["null_resource.create_master_ssh_key","null_resource.create_compute_ssh_key","ibm_is_instance.master","ibm_is_floating_ip.fipcompute"]
}

resource "null_resource" "install-master" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${ibm_is_floating_ip.fipmaster.address}"
    private_key = "${data.local_file.deployer_ssh_private_key.content}"
  }

  provisioner "remote-exec" {
    inline  = [
      ". /root/installer/install.sh master ${local.parameters}",
    ]
  }

  depends_on = ["null_resource.pre-install-master","null_resource.pre-install-compute"]
}


resource "null_resource" "install-compute" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${element(ibm_is_floating_ip.fipcompute.*.address,count.index)}"
    private_key = "${data.local_file.deployer_ssh_private_key.content}"
  }
  count = "${var.num_computes}"

  provisioner "remote-exec" {
    inline  = [
      ". /root/installer/install.sh compute ${local.parameters}",
    ]
  }

  depends_on = ["null_resource.install-master"]
}


resource "null_resource" "post-install-master" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${ibm_is_floating_ip.fipmaster.address}"
    private_key = "${data.local_file.deployer_ssh_private_key.content}"
  }

  provisioner "remote-exec" {
    inline  = [
      ". /root/installer/post-install.sh master ${local.parameters}",
      ". /root/installer/clean.sh master",
    ]
  }

  depends_on = ["null_resource.install-master","null_resource.install-compute"]
}

resource "null_resource" "post-install-compute" {
  connection {
    type        = "ssh"
    user        = "root"
    host        = "${element(ibm_is_floating_ip.fipcompute.*.address,count.index)}"
    private_key = "${data.local_file.deployer_ssh_private_key.content}"
  }
  count = "${var.num_computes}"
  provisioner "remote-exec" {
    inline  = [
      ". /root/installer/post-install.sh compute ${local.parameters}",
      ". /root/installer/clean.sh compute",
    ]
  }

  depends_on = ["null_resource.post-install-master"]
}

