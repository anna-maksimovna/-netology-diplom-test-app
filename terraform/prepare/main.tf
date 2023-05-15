terraform {
  required_version = ">= 1.0.0"

  required_providers {
    yandex = {
      source = "yandex-cloud/yandex"
    }
  }
}

provider "yandex" {
  token     = "${var.yc_token}"
  cloud_id  = "b1gukgdippc16e20ecq2"
  folder_id = "b1gc741a1hebsb16m99q"
  zone      = "ru-central1-a"
}