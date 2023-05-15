# Дипломный практикум в Yandex.Cloud
  * [Цели:](#цели)
  * [Этапы выполнения:](#этапы-выполнения)
     * [Создание облачной инфраструктуры](#создание-облачной-инфраструктуры)
     * [Создание Kubernetes кластера](#создание-kubernetes-кластера)
     * [Создание тестового приложения](#создание-тестового-приложения)
     * [Подготовка cистемы мониторинга и деплой приложения](#подготовка-cистемы-мониторинга-и-деплой-приложения)
     * [Установка и настройка CI/CD](#установка-и-настройка-cicd)
  * [Что необходимо для сдачи задания?](#что-необходимо-для-сдачи-задания)
  * [Как правильно задавать вопросы дипломному руководителю?](#как-правильно-задавать-вопросы-дипломному-руководителю)

---
## Цели:

1. Подготовить облачную инфраструктуру на базе облачного провайдера Яндекс.Облако.
2. Запустить и сконфигурировать Kubernetes кластер.
3. Установить и настроить систему мониторинга.
4. Настроить и автоматизировать сборку тестового приложения с использованием Docker-контейнеров.
5. Настроить CI для автоматической сборки и тестирования.
6. Настроить CD для автоматического развёртывания приложения.

---
## Результаты:

1. Приложение. [http://84.201.131.45/](http://84.201.131.45/).
2. Grafana (netology/netology)  [http://51.250.79.162/](http://51.250.79.162/).

---
## Этапы выполнения:


### Создание облачной инфраструктуры

В папке terraform/[prepare](https://github.com/anna-maksimovna/netology-diplom/tree/main/terraform/prepare) выполнила команды:
```
terraform init
//создаем воркспейсы:
terraform workspace new prod
terraform workspace new stage //(он будет активным)
terraform workspace list
terraform validate
terraform plan
```

---
### Создание Kubernetes кластера

Копирнула ключи из стейтов в terraform/prepare и прописала в main.tf
В папке terraform/[main](https://github.com/anna-maksimovna/netology-diplom/tree/main/terraform/main) выполнила команды:
```
terraform init
//создаем воркспейсы:
terraform workspace new prod
terraform workspace new stage //(он будет активным)
terraform workspace list
terraform validate
terraform plan
```

Сам кластер развернут с помощью [Kubespray](https://kubernetes.io/docs/setup/production-environment/tools/kubespray/) 
в папке kubespray\inventory копируем папку sample и называем netologyCluster (kubespray\inventory\netologyCluster)
В папке kubespray:
Объявляем адреса вм созданных:
```
declare -a IPS=(51.250.87.170 84.201.144.15 158.160.3.183 158.160.44.21)
```
генерим host.yml:
```
CONFIG_FILE=inventory/netologyCluster/hosts.yaml python3 contrib/inventory_builder/inventory.py ${IPS[@]}
```
Запускаем развертывание кластера:
```
ansible-playbook -i inventory/netologyCluster/hosts.yaml  --become --become-user=root cluster.yml -b -v
```

> В [kubespray](https://github.com/anna-maksimovna/netology-diplom/tree/main/kubespray) поменяла максимальную версию ansible в файлике ansible_version.yml
> Была еще ошибка, нашла таск, где она была и поставила там в no_log false (файл kubespray\roles\download\tasks\download_file.yml  строка 104)
> Запустила опять плейбук, выдал что чек сумма неверная при скачивании файла calico версии 3.25.1, нашла версии калико и поменяла на 3.25.0 в файле kubespray\roles\download\defaults\main.yml  строка 106

Проверила, что кластер развернулся:
```
kubectl get nodes
```
---
### Создание тестового приложения

Тестовое [приложение](https://github.com/anna-maksimovna/netology-diplom/tree/main/test-app)
[Dockerfile](https://github.com/anna-maksimovna/netology-diplom/blob/main/test-app/Dockerfile)

---
### Подготовка cистемы мониторинга и деплой приложения

Установила go по [инструкции](https://tecadmin.net/how-to-install-go-on-ubuntu-20-04/):
```
sudo apt-get update  
sudo apt-get -y upgrade 
sudo wget https://go.dev/dl/go1.17.13.linux-amd64.tar.gz
sudo tar -C /usr/local -xzf go1.17.13.linux-amd64.tar.gz
//следующие команды надо запускать каждый раз, как перезапускаем терминал:
export GOROOT=/usr/local/go
export GOPATH=$HOME/Projects/Proj1
export PATH=$GOPATH/bin:$GOROOT/bin:$PATH
```

Далее устанавливаем [kube-prometheus](https://github.com/prometheus-operator/kube-prometheus) по инструкции:
```
go install -a github.com/jsonnet-bundler/jsonnet-bundler/cmd/jb@latest
mkdir my-kube-prometheus; cd my-kube-prometheus
jb init
jb install github.com/prometheus-operator/kube-prometheus/jsonnet/kube-prometheus@main
wget https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/example.jsonnet -O example.jsonnet
wget https://raw.githubusercontent.com/prometheus-operator/kube-prometheus/main/build.sh -O build.sh
chmod +x build.sh
go install github.com/brancz/gojsontoyaml@latest
go install github.com/google/go-jsonnet/cmd/jsonnet@latest
```
Изменила файл [example.jsonnet](https://github.com/anna-maksimovna/netology-diplom/blob/main/my-kube-prometheus/example.jsonnet) и далее запускаем развертывание:
```
./build.sh example.jsonnet
kubectl apply --server-side -f manifests/setup
kubectl apply -f manifests/
```

---
### Установка и настройка CI/CD

Для настройки ci/cd использовала GitLab. Файлы соответственно находятся в [папке](https://github.com/anna-maksimovna/netology-diplom/tree/main/test-app) приложения.


