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

resource "alicloud_instance" "web" {
  count                      = "${var.web_instance_count}"
  instance_name              = "${var.web_layer_name}-${count.index}-srv"
  instance_type              = "${var.web_instance_type}"
  system_disk_category       = "cloud_efficiency"
  image_id                   = "${var.web_instance_image_id}"

  availability_zone          = "${var.region}${var.web_availability_zone}"
  vswitch_id                 = "${alicloud_vswitch.web.id}"

  security_groups            = ["${alicloud_security_group.web.id}"]
  user_data                  = "${var.web_instance_user_data}"
}

resource "alicloud_slb" "web" {
  name        = "${var.web_layer_name}-slb"
  internet    = true
  internet_charge_type = "paybytraffic"
}

 resource "alicloud_slb_listener" "web" {
   load_balancer_id = "${alicloud_slb.web.id}"
   backend_port     = "${var.web_instance_port}"
   frontend_port    = "${var.web_instance_port}"
   protocol         = "http"
   bandwidth        = "5"
 }

resource "alicloud_slb_attachment" "web" {
  load_balancer_id    = "${alicloud_slb.web.id}"
  instance_ids = ["${alicloud_instance.web.*.id}"]
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

resource "alicloud_instance" "app" {
  count                      = "${var.app_instance_count}"
  instance_name              = "${var.app_layer_name}-${count.index}-srv"
  instance_type              = "${var.app_instance_type}"
  system_disk_category       = "cloud_efficiency"
  image_id                   = "${var.app_instance_image_id}"

  availability_zone          = "${var.region}${var.app_availability_zone}"
  vswitch_id                 = "${alicloud_vswitch.app.id}"

  security_groups            = ["${alicloud_security_group.app.id}"]
  user_data                  = "${var.app_instance_user_data}"
}

resource "alicloud_slb" "app" {
  name        = "${var.app_layer_name}-slb"
  internet    = false
  internet_charge_type = "paybytraffic"
  vswitch_id = "${alicloud_vswitch.app.id}"
}

 resource "alicloud_slb_listener" "app" {
   load_balancer_id = "${alicloud_slb.app.id}"
   backend_port     = "${var.app_instance_port}"
   frontend_port    = "${var.app_instance_port}"
   protocol         = "http"
   bandwidth        = "5"
 }

resource "alicloud_slb_attachment" "app" {
  load_balancer_id    = "${alicloud_slb.app.id}"
  instance_ids = ["${alicloud_instance.app.*.id}"]
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
    instance_type = "${var.db_instance_type}"
    instance_storage = "${var.db_instance_storage}"

    vswitch_id = "${alicloud_vswitch.db.id}"
    security_ips = ["10.0.2.0/24"]
}
