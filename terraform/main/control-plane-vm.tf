data "yandex_compute_image" "ubuntu-2004" {
  family = "ubuntu-2004-lts"
}

resource "yandex_compute_instance" "control-plane-vm" {
  name     = format("control-plane-vm-%s", terraform.workspace)
  hostname = format("control-plane-vm-%s", terraform.workspace)
  zone     = local.zones.a.zone_name

  resources {
    cores  = 2
    memory = 2
  }

  boot_disk {
    initialize_params {
      image_id = data.yandex_compute_image.ubuntu-2004.id
      size     = 50
    }
  }

  network_interface {
    subnet_id = yandex_vpc_subnet.public[local.zones.a.name].id
    nat       = true
  }

  scheduling_policy {
    preemptible = false
  }

  metadata = {
    ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
  }
}
