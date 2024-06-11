terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = var.yc_zone
  token = var.yc_token
  folder_id = var.yc_folder
}

resource "yandex_compute_disk" "boot-disk" {
  count = 2
  name        = "boot-disk-${count.index}"
  size        = "20"
  type        = "network-hdd"
  zone        = "ru-central1-a"
  image_id    = var.os_image
}

resource "yandex_vpc_network" "default" {
    name = "project"
}

resource "yandex_vpc_subnet" "web" {
  zone           = "ru-central1-a"
  network_id     = "${yandex_vpc_network.default.id}"
  v4_cidr_blocks = ["192.168.0.0/24"]
}

resource "yandex_compute_instance" "web" {
  count = 2
  name        = "web-${count.index}"
  platform_id = "standard-v1"
  zone        = "ru-central1-a"

  resources {
    core_fraction = 5
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.boot-disk[count.index].id
  }

  network_interface {
    subnet_id = "${yandex_vpc_subnet.web.id}"
    nat = true
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    ssh-keys = "${var.yc_user}:${file("~/.ssh/id_rsa.pub")}"
  }

  connection {
    type        = "ssh"
    user        = var.yc_user
    private_key = file("~/.ssh/id_rsa")
    host        = self.network_interface[0].nat_ip_address
  }
  
}


resource "yandex_lb_network_load_balancer" "lb" {
  name = "project-lb"
  
  listener {
    name = "http"
    port = 80
    target_port = 80
    external_address_spec {}
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.web.id

    healthcheck {
      name = "http"
      http_options {
        port = 80
        path = "/"
      }
      interval = 2
      timeout = 1
      unhealthy_threshold = 3
      healthy_threshold = 2
    }
  }
}

resource "yandex_lb_target_group" "web" {
  name = "project-target-group"

  dynamic "target" {
    for_each = yandex_compute_instance.web[*].network_interface.0.ip_address
    content {
      address   = target.value
      subnet_id = yandex_vpc_subnet.web.id
    }
  }
}

resource "yandex_mdb_postgresql_cluster" "dbcluster" {
  name        = "project-cluster"
  environment = "PRODUCTION"
  network_id  = yandex_vpc_network.default.id

  config {
    version = 13
    resources {
      resource_preset_id = "s2.micro"
      disk_type_id       = "network-ssd"
      disk_size          = 15
    }
    postgresql_config = {
      max_connections    = 100
    }
  }

  maintenance_window {
    type = "WEEKLY"
    day  = "SAT"
    hour = 12
  }

  host {
    zone      = "ru-central1-a"
    subnet_id = yandex_vpc_subnet.web.id
  }
}

resource "yandex_mdb_postgresql_user" "dbuser" {
  cluster_id = yandex_mdb_postgresql_cluster.dbcluster.id
  name       = var.db_user
  password   = var.db_password
  depends_on = [yandex_mdb_postgresql_cluster.dbcluster]
}

resource "yandex_mdb_postgresql_database" "db" {
  cluster_id = yandex_mdb_postgresql_cluster.dbcluster.id
  name       = var.db_name
  owner      = yandex_mdb_postgresql_user.dbuser.name
  lc_collate = "en_US.UTF-8"
  lc_type    = "en_US.UTF-8"
  depends_on = [yandex_mdb_postgresql_cluster.dbcluster]
}

output "ansible_inventory" {
  value = <<-DOC
    [webservers]
    %{~ for i in yandex_compute_instance.web ~}
    ${i.name} ansible_host=${i.network_interface[0].nat_ip_address}
    %{~ endfor ~}
    DOC
}

output "database_credentials" {
  value     = <<-DOC
    db_host: ${yandex_mdb_postgresql_cluster.dbcluster.host.0.fqdn}
    DOC
}