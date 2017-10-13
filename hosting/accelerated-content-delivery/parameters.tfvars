web_layer_name = "web"
web_availability_zone = "a"
web_instance_count = 4
web_instance_type = "ecs.n4.small"
web_instance_port = 80
web_instance_image_id = "ubuntu_16_0402_64_20G_alibase_20170818.vhd"
web_instance_user_data = ""

app_layer_name = "app"
app_availability_zone = "a"
app_instance_count = 4
app_instance_type = "ecs.n4.small"
app_instance_port = 5000
app_instance_image_id = "ubuntu_16_0402_64_20G_alibase_20170818.vhd"
app_instance_user_data = ""

db_layer_name = "db"
db_availability_zone = "a"
db_engine = "MySQL"
db_engine_version = "5.6"
db_instance_type = "rds.mysql.t1.small"
db_instance_storage = 10