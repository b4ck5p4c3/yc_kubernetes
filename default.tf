terraform {
  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
  required_version = ">= 0.13"
}

variable "zones" {
  type = list(string)
  default = ["ru-central1-a", "ru-central1-b", "ru-central1-d"]
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

  name = "terraform${count.index}"
  zone = var.zones[count.index]
  platform_id = var.zones[count.index] == "ru-central1-d" ? "standard-v3" : "standard-v1"
  
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.kuber_disks[count.index].id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.kuber_subnets[count.index].id
    nat = true
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
