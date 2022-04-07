# Сценарии iptables

## Задание

Реализовать port knocking

- centralRouter может попасть на ssh inetRouter через knock скрипт пример в материалах;
- добавить inetRouter2, который виден(маршрутизируется (host-only тип сети для виртуалки)) с хоста или форвардится порт через локалхост;
- запустить nginx на centralServer;
- пробросить 80 порт на inetRouter2 8080;
- дефолт в инет оставить через inetRouter;
- *реализовать проход на 80 порт без маскарадинга.

Формат сдачи ДЗ — vagrant + ansible

## Структура стенда

`Vagrantfile` — файл базовой конфигурации виртуального стенда

`provisioning/*` — файлы конфигурации для настройки стенда с помощью ansible

## Решение

Запуск стенда: `vagrant up`

Для включения port knocking на inetRouter необходимо выполнить:

```
vagrant ssh inetRouter
sudo systemctl start iptables.service
```

Затем последовательно выполнить на centralRouter:

```
vagrant ssh centralRouter
nmap -Pn --host-timeout 100 --max-retries 0 -p 8881 192.168.20.1
nmap -Pn --host-timeout 100 --max-retries 0 -p 7777 192.168.20.1
nmap -Pn --host-timeout 100 --max-retries 0 -p 9991 192.168.20.1
ssh vagrant@192.168.20.1
```
