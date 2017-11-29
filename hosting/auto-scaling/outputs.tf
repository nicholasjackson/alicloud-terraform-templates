output "slb_web_public_ip" {
  value = "${alicloud_slb.web.address}"
}