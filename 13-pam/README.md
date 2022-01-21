# PAM

## Задание

- запретить всем пользователям, кроме группы `admin`, логин в выходные (суббота и воскресенье), без учёта праздников
- дать конкретному пользователю права работать с докером и возможность рестартить докер сервис

## Структура стенда

`Vagrantfile` — файл базовой конфигурации виртуального стенда

`login_script.sh` — сценарий входа на bash (для задания №1)

## Решение

Запустить стенд: `vagrant up`

Подключиться к стенду: `vagrant ssh`

Попробовать авторизоваться под пользователем `test1`:

```bash
[vagrant@localhost ~]$ su - test1
Password:
Last login: Thu Jan 20 12:07:53 UTC 2022 on pts/0
[test1@localhost ~]$
[vagrant@localhost ~]$ id test1
uid=1001(test1) gid=1002(test1) groups=1002(test1),1001(admin)
```

Вход выполняется успешно, так как пользователь `test1` состоит в группе `admin`.

При попытке войти под пользователем `test2` — отказ, так как он не состоит в группе `admin`:

```bash
[vagrant@localhost ~]$ su - test2
Password:
su: System error
[vagrant@localhost ~]$
[vagrant@localhost ~]$ id test2
uid=1002(test2) gid=1003(test2) groups=1003(test2)
```

Также для пользователя `test1` выданы права через `sudoers` (без запроса пароля) на работу с докером и перезапуск службы докера:

```bash
[test1@localhost ~]$ sudo docker pull centos
Using default tag: latest
latest: Pulling from library/centos
a1d0c7532777: Pull complete
Digest: sha256:a27fd8080b517143cbbbab9dfb7c8571c40d67d534bbdee55bd6c473f432b177
Status: Downloaded newer image for centos:latest
docker.io/library/centos:latest
[test1@localhost ~]$
[test1@localhost ~]$ sudo systemctl restart docker.service
[test1@localhost ~]$
```
