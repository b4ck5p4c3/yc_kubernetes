resource "yandex_vpc_network" "kuber_net" {
  name = "kuber_network"
}

resource "yandex_vpc_address" "kuber_addresses" {
  count = length(var.zones)

  name = "kuber_addr${count.index}"

  external_ipv4_address {
    zone_id = var.zones[count.index]
  }
}

resource "yandex_vpc_subnet" "kuber_subnets" {
  count = length(var.zones)

  v4_cidr_blocks = ["10.1${count.index}.0.0/24"]
  zone           = var.zones[count.index]
  network_id     = yandex_vpc_network.kuber_net.id
}