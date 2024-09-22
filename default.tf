terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

provider "yandex" {
  zone = "ru-central1-a"
}

variable "zones" {
  type    = list(string)
  default = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
}

variable "kubeapi_port" {
  type = number 
  default = 8080
}

resource "yandex_compute_disk" "kuber_disks" {
  count = length(var.zones)

  name     = "kuber-${count.index}"
  type     = "network-ssd"
  zone     = var.zones[count.index]
  size     = "93"
  image_id = "fd83h72fb5urnmt6vkfd"
}

resource "yandex_compute_placement_group" "kuber_pg" {
  name = "kuber"
}

resource "yandex_vpc_network" "kuber_net" {
  name = "kuber_network"
}

resource "yandex_vpc_subnet" "kuber_subnets" {
  count = length(var.zones)

  v4_cidr_blocks = ["10.1${count.index}.0.0/24"]
  zone           = var.zones[count.index]
  network_id     = yandex_vpc_network.kuber_net.id
}

resource "yandex_vpc_address" "kuber_addresses" {
  count = length(var.zones)

  name = "kuber_addr${count.index}"

  external_ipv4_address {
    zone_id = var.zones[count.index]
  }
}

resource "yandex_compute_instance" "kuber_instances" {
  count = length(var.zones)

  name        = "terraform${count.index}"
  zone        = var.zones[count.index]
  platform_id = var.zones[count.index] == "ru-central1-d" ? "standard-v3" : "standard-v1"

  resources {
    cores  = 2
    memory = 2
    core_fraction = 20
  }

  boot_disk {
    disk_id = yandex_compute_disk.kuber_disks[count.index].id
  }

  network_interface {
    subnet_id      = yandex_vpc_subnet.kuber_subnets[count.index].id
    nat            = true
    nat_ip_address = yandex_vpc_address.kuber_addresses[count.index].external_ipv4_address[0].address
  }

  placement_policy {
    placement_group_id = yandex_compute_placement_group.kuber_pg.id
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    enable-oslogin = true
  }
}

resource "yandex_lb_target_group" "kuber_lb_target_group" {

  name      = "kuber-target-group"
  region_id = "ru-central1"
  dynamic "target" {
    for_each = toset(var.zones)

    content {
      subnet_id = yandex_vpc_subnet.kuber_subnets[index(var.zones, target.key)].id
      address   = yandex_compute_instance.kuber_instances[index(var.zones, target.key)].network_interface.0.ip_address
    }
  }
}

resource "yandex_lb_network_load_balancer" "kuber_lb" {
  name = "kuber-lb"

  listener {
    name = "kubeapi"
    port = var.kubeapi_port
    external_address_spec {
      ip_version = "ipv4"
    }
  }

  attached_target_group {
    target_group_id = yandex_lb_target_group.kuber_lb_target_group.id

    healthcheck {
      name = "kubeapi"
      http_options {
        port = var.kubeapi_port
        path = "/ping"
      }
    }
  }
}