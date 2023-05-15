resource "yandex_container_registry" "netology-registry" {
  name      = "netology-registry"
  folder_id = local.folder_id
}
