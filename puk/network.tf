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

resource "yandex_vpc_network" "test" {
  name = "test_interconnect"
}

resource "yandex_vpc_subnet" "test_subnet_a" {
  v4_cidr_blocks = ["10.10.0.0/24"]
  zone           = "ru-central1-a"
  network_id     = yandex_vpc_network.test.id
}

resource "yandex_vpc_subnet" "test_subnet_b" {
  v4_cidr_blocks = ["10.11.0.0/24"]
  zone           = "ru-central1-b"
  network_id     = yandex_vpc_network.test.id
}

resource "yandex_vpc_subnet" "test_subnet_d" {
  v4_cidr_blocks = ["10.12.0.0/24"]
  zone           = "ru-central1-d"
  network_id     = yandex_vpc_network.test.id
}

resource "yandex_compute_disk" "test-a-disk" {
  name     = "test-interconnect-a"
  type     = "network-hdd"
  zone     = "ru-central1-a"
  size     = "20"
  image_id = "fd80293ig2816a78q276"
}

resource "yandex_compute_disk" "test-b-disk" {
  name     = "test-interconnect-b"
  type     = "network-hdd"
  zone     = "ru-central1-b"
  size     = "20"
  image_id = "fd80293ig2816a78q276"
}

resource "yandex_compute_disk" "test-d-disk" {
  name     = "test-interconnect-d"
  type     = "network-hdd"
  zone     = "ru-central1-d"
  size     = "20"
  image_id = "fd80293ig2816a78q276"
}

resource "yandex_compute_instance" "test-a" {
  name = "test-interconnect-a"
  zone = "ru-central1-a"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.test-a-disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.test_subnet_a.id
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "test-b" {
  name = "test-interconnect-b"
  zone = "ru-central1-b"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.test-b-disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.test_subnet_b.id
  }

  scheduling_policy {
    preemptible = true
  }
}

resource "yandex_compute_instance" "test-d" {
  name        = "test-interconnect-d"
  zone        = "ru-central1-d"
  platform_id = "standard-v3"

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    disk_id = yandex_compute_disk.test-d-disk.id
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.test_subnet_d.id
  }

  scheduling_policy {
    preemptible = true
  }

  metadata = {
    enable-oslogin = true
  }
}
