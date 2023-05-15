resource "yandex_compute_instance_group" "worker-nodes-group" {
  name               = format("workers-group-%s", terraform.workspace)
  folder_id          = yandex_iam_service_account.netology-cluster-service-account.folder_id
  service_account_id = yandex_iam_service_account.netology-cluster-service-account.id
  depends_on         = [yandex_resourcemanager_folder_iam_member.sa-editor]

  instance_template {
    resources {
      memory = 2
      cores  = 2
    }
    boot_disk {
      mode = "READ_WRITE"
      initialize_params {
        image_id = data.yandex_compute_image.ubuntu-2004.id
        size     = 50
      }
    }

    network_interface {
      subnet_ids = [yandex_vpc_subnet.public[local.zones.a.name].id, yandex_vpc_subnet.public[local.zones.b.name].id, yandex_vpc_subnet.public[local.zones.c.name].id]
      nat        = true
    }

    metadata = {
      ssh-keys = "ubuntu:${file("~/.ssh/id_rsa.pub")}"
    }
  }

  scale_policy {
    fixed_scale {
      size = 3
    }
  }

  allocation_policy {
    zones = [local.zones.a.zone_name, local.zones.b.zone_name, local.zones.c.zone_name]
  }

  deploy_policy {
    max_unavailable = 1
    max_expansion   = 0
  }
}
