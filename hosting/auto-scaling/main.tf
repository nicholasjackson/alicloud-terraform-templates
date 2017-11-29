provider "alicloud" {
  access_key = "${var.access_key_id}"
  secret_key = "${var.access_key_secret}"
  region     = "${var.region}"
  version    = "~> 0.1"
}

resource "alicloud_vpc" "default" {
  name        = "${var.solution_name}-vpc"
  description = "VPC for hosting ${var.solution_name} solution"
  cidr_block  = "10.0.0.0/16"
}

resource "alicloud_vswitch" "web" {
  vpc_id            = "${alicloud_vpc.default.id}"
  cidr_block        = "10.0.1.0/24"
  availability_zone = "${var.region}${var.web_availability_zone}"
}

resource "alicloud_vswitch" "app" {
  vpc_id            = "${alicloud_vpc.default.id}"
  cidr_block        = "10.0.2.0/24"
  availability_zone = "${var.region}${var.app_availability_zone}"
}

resource "alicloud_vswitch" "db" {
  vpc_id            = "${alicloud_vpc.default.id}"
  cidr_block        = "10.0.3.0/24"
  availability_zone = "${var.region}${var.db_availability_zone}"
}

resource "alicloud_ess_scaling_group" "web" {
  scaling_group_name = "scaling-group-web"
  min_size           = "${var.web_instance_min_count}"
  max_size           = "${var.web_instance_max_count}"

  removal_policies   = ["OldestInstance", "NewestInstance"]
  loadbalancer_ids   = ["${alicloud_slb.web.id}"]

  vswitch_id                 = "${alicloud_vswitch.web.id}"
}

resource "alicloud_ess_scaling_configuration" "web" {
  scaling_configuration_name = "scaling-configuration-web"
  scaling_group_id           = "${alicloud_ess_scaling_group.web.id}"

  instance_type              = "${var.web_instance_type}"
  io_optimized               = "optimized"
  system_disk_category       = "cloud_efficiency"
  image_id                   = "${var.web_instance_image_id}"

  security_group_id          = "${alicloud_security_group.web.id}"
  active                     = true
}

resource "alicloud_ess_scaling_rule" "web" {
  scaling_rule_name = "scaling-rule-web"
  scaling_group_id  = "${alicloud_ess_scaling_group.web.id}"

  adjustment_type   = "TotalCapacity"
  adjustment_value  = 2
  cooldown          = 60
}

resource "alicloud_slb" "web" {
  name        = "${var.web_layer_name}-slb"
  internet    = true
  internet_charge_type = "paybytraffic"

  listener = [
    {
      "instance_port" = "${var.web_instance_port}"
      "lb_port"       = "${var.web_instance_port}"
      "lb_protocol"   = "http"
      "bandwidth"     = "5"
    }
  ]
}

resource "alicloud_security_group" "web" {
  name   = "${var.web_layer_name}-sg"
  vpc_id = "${alicloud_vpc.default.id}"
}

resource "alicloud_security_group_rule" "allow_web_access" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "${var.web_instance_port}/${var.web_instance_port}"
  priority          = 1
  security_group_id = "${alicloud_security_group.web.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_ess_scaling_group" "app" {
  scaling_group_name = "scaling-group-app"
  min_size           = "${var.app_instance_min_count}"
  max_size           = "${var.app_instance_max_count}"

  removal_policies   = ["OldestInstance", "NewestInstance"]
  loadbalancer_ids   = ["${alicloud_slb.app.id}"]
  db_instance_ids    = ["${alicloud_db_instance.default.id}"]

  vswitch_id                 = "${alicloud_vswitch.app.id}"
}

resource "alicloud_ess_scaling_configuration" "app" {
  scaling_configuration_name = "scaling-configuration-app"
  scaling_group_id           = "${alicloud_ess_scaling_group.app.id}"

  instance_type              = "${var.app_instance_type}"
  io_optimized               = "optimized"
  system_disk_category       = "cloud_efficiency"
  image_id                   = "${var.app_instance_image_id}"

  security_group_id          = "${alicloud_security_group.app.id}"
  active                     = true
}

resource "alicloud_ess_scaling_rule" "app" {
  scaling_rule_name = "scaling-rule-app"
  scaling_group_id  = "${alicloud_ess_scaling_group.app.id}"

  adjustment_type   = "TotalCapacity"
  adjustment_value  = 2
  cooldown          = 60
}

resource "alicloud_slb" "app" {
  name        = "${var.app_layer_name}-slb"
  internet    = false
  internet_charge_type = "paybytraffic"
  vswitch_id = "${alicloud_vswitch.app.id}"

  listener = [
    {
      "instance_port" = "${var.app_instance_port}"
      "lb_port"       = "${var.app_instance_port}"
      "lb_protocol"   = "tcp"
      "bandwidth"     = "5"
    }
  ]
}

resource "alicloud_security_group" "app" {
  name   = "${var.web_layer_name}-sg"
  vpc_id = "${alicloud_vpc.default.id}"
}

resource "alicloud_security_group_rule" "allow_app_access" {
  type              = "ingress"
  ip_protocol       = "tcp"
  nic_type          = "intranet"
  policy            = "accept"
  port_range        = "${var.app_instance_port}/${var.app_instance_port}"
  priority          = 1
  security_group_id = "${alicloud_security_group.app.id}"
  cidr_ip           = "0.0.0.0/0"
}

resource "alicloud_db_instance" "default" {
    engine = "${var.db_engine}"
    engine_version = "${var.db_engine_version}"
    db_instance_class = "${var.db_instance_type}"
    db_instance_storage = "${var.db_instance_storage}"

    db_instance_net_type = "Intranet"
    instance_network_type = "VPC"

    vswitch_id = "${alicloud_vswitch.db.id}"
    security_ips = ["10.0.2.0/24"]
}