resource "yandex_compute_disk" "kuber_disks" {
  count = length(var.zones)

  name     = "kuber-${count.index}"
  type     = "network-ssd"
  zone     = var.zones[count.index]
  size     = "20"
  image_id = "fd84uoseqemi8gihbs05"
}

resource "yandex_compute_placement_group" "kuber_pg" {
  name = "kuber"
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
