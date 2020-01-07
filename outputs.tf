# IP address of hosts

output "master_float_ip_address" {
  value = "http://${ibm_is_floating_ip.fipmaster.address}"
}