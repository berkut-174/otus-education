# OSPF

## Задание

1. Поднять три виртуалки
2. Объединить их разными vlan
    - поднять OSPF между машинами на базе Quagga;
    - изобразить асимметричный роутинг;
    - сделать один из линков "дорогим", но чтобы при этом роутинг был симметричным.

Формат сдачи ДЗ — vagrant + ansible.

## Структура стенда

`Vagrantfile` — файл базовой конфигурации виртуального стенда

`provisioning/*` — файлы конфигурации для настройки стенда с помощью ansible

## Решение

Запуск стенда: `vagrant up`

Управляемые параметры в файле `provisioning/defaults/main.yml`:

```
router_id_enable: false
symmetric_routing: false
```

`symmetric_routing` — переключение между асимметричным и симметричным роутингом

`router_id_enable` — добавление параметра `router-id` в конфигурацию frr

Запуск плейбука после изменения управляемых параметров:

```
cd /vagrant
ansible-playbook -i provisioning/hosts -l all provisioning/playbooks/routers.yml -t setup_ospf -e "host_key_checking=false"
```
