# LDAP

## Задание

1. Установить FreeIPA;
2. Написать Ansible playbook для конфигурации клиента;
3. *Настроить аутентификацию по SSH-ключам;
4. **Firewall должен быть включен на сервере и на клиенте.

Формат сдачи ДЗ — vagrant + ansible.

## Структура стенда

`Vagrantfile` — файл базовой конфигурации виртуального стенда

`provisioning/*` — файлы конфигурации для настройки стенда с помощью ansible

## Решение

Основой для стенда выступает набор готовых плейбуков и ролей для FreeIPA от разработчиков https://github.com/freeipa/ansible-freeipa. В мой проект был подключен модуль со ссылкой на этот репозиторий. Предварительно была сделана его доработка под особенности вагрант и в соответствие с заданием.

Запуск стенда: `vagrant up`

Подключаемся к клиенту: `vagrant ssh client`

Проверяем получение тикета (пароль `MySecretPassword123`):

```
[vagrant@ipaclient ~]$ kinit admin
Password for admin@OTUSTEST.COM:
```

```
[vagrant@ipaclient ~]$ klist
Ticket cache: KCM:1000
Default principal: admin@OTUSTEST.COM

Valid starting     Expires            Service principal
04/12/22 10:37:18  04/13/22 10:37:12  krbtgt/OTUSTEST.COM@OTUSTEST.COM
```

Авторизация проходит успешно, тикет получен.
