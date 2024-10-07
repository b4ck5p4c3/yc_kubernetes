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
