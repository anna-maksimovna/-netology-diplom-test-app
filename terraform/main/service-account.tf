resource "yandex_iam_service_account" "netology-cluster-service-account" {
  name = format("netology-cluster-service-account-%s", terraform.workspace)
}

resource "yandex_resourcemanager_folder_iam_member" "sa-editor" {
  folder_id  = yandex_iam_service_account.netology-cluster-service-account.folder_id
  role       = "editor"
  member     = "serviceAccount:${yandex_iam_service_account.netology-cluster-service-account.id}"
  depends_on = [yandex_iam_service_account.netology-cluster-service-account]
}

resource "yandex_iam_service_account" "netology-registry-service-account" {
  name = "netology-registry-service-account"
}

resource "yandex_iam_service_account_key" "netology-registry-service-account-key" {
  service_account_id = yandex_iam_service_account.netology-registry-service-account.id
  description        = "SA key for docker registry agent"
  depends_on = [
    yandex_iam_service_account.netology-registry-service-account
  ]
}

resource "yandex_container_registry_iam_binding" "netology-registry-sa-pusher" {
  registry_id = yandex_container_registry.netology-registry.id
  role        = "container-registry.images.pusher"
  members     = ["serviceAccount:${yandex_iam_service_account.netology-registry-service-account.id}"]
  depends_on = [
    yandex_iam_service_account.netology-registry-service-account,
    yandex_iam_service_account_key.netology-registry-service-account-key,
    yandex_container_registry.netology-registry
  ]
}

resource "yandex_container_registry_iam_binding" "netology-registry-sa-puller" {
  registry_id = yandex_container_registry.netology-registry.id
  role        = "container-registry.images.puller"
  members = [
    "serviceAccount:${yandex_iam_service_account.netology-registry-service-account.id}"
  ]
  depends_on = [
    yandex_iam_service_account.netology-registry-service-account,
    yandex_iam_service_account_key.netology-registry-service-account-key,
    yandex_container_registry.netology-registry
  ]
}
