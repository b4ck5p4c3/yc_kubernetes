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

resource "yandex_compute_disk" "kuber-a-disk" {
  name     = "kuber-a"
  type     = "network-ssd-nonreplicated"
  zone     = "ru-central1-a"
  size     = "93"
  image_id = "fd83h72fb5urnmt6vkfd"
}

resource "yandex_compute_placement_group" "kuber" {
    name = "kuber"
}

resource "yandex_compute_instance" "kuber-a" {
  name = "terraform1"
  
  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.kuber-a-disk.id
  }

  network_interface {
    subnet_id = "e9brf3q098gs97db97ma"
  }

  placement_policy {
    placement_group_id = yandex_compute_placement_group.kuber.id
  }

  scheduling_policy {
    preemptible = true
  }
}


