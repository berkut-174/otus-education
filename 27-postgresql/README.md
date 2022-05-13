# Репликация PostgreSQL

## Задание

1. На 1 ВМ создаем таблицы test для записи, test2 для запросов на чтение.
   Создаем публикацию таблицы test и подписываемся на публикацию таблицы test2 с ВМ №2.
2. На 2 ВМ создаем таблицы test2 для записи, test для запросов на чтение.
   Создаем публикацию таблицы test2 и подписываемся на публикацию таблицы test1 с ВМ №1.
3. ВМ 3 использовать как реплику для чтения (подписаться на таблицы из ВМ №1 и №2).
   Реализовать горячее реплицирование для высокой доступности на 4 ВМ и бэкапов.

## Структура стенда

`Vagrantfile` — файл базовой конфигурации виртуального стенда

`provisioning/*` — файлы конфигурации для настройки стенда с помощью ansible

## Решение

Запуск стенда: `vagrant up`.

Подключение к ВМ: `vagrant ssh <vm>`, где `<vm>` — имя ВМ.

### Выполняем настройку для `vm1`

Переходим в терминал PostgreSQL:
```
vagrant@vm1:~$ sudo -u postgres psql
psql (12.10 (Ubuntu 12.10-0ubuntu0.20.04.1))
Type "help" for help.
```

Переключаемся на БД `otus`:
```
postgres=# \c otus
You are now connected to database "otus" as user "postgres".
```

Выполняем подписку на таблицу `test2`:
```
otus=# CREATE SUBSCRIPTION sub_test2
otus-# CONNECTION 'host=192.168.255.2 port=5432 user=otususer password=pas123 dbname=otus'
otus-# PUBLICATION pub_test2 WITH (copy_data = true);
NOTICE:  created replication slot "sub_test2" on publisher
CREATE SUBSCRIPTION
```

### Выполняем настройку для `vm2`

Переходим в терминал PostgreSQL:
```
vagrant@vm2:~$ sudo -u postgres psql
psql (12.10 (Ubuntu 12.10-0ubuntu0.20.04.1))
Type "help" for help.
```

Переключаемся на БД `otus`:
```
postgres=# \c otus
You are now connected to database "otus" as user "postgres".
```

Выполняем подписку на таблицу `test`:
```
otus=# CREATE SUBSCRIPTION sub_test
otus-# CONNECTION 'host=192.168.255.1 port=5432 user=otususer password=pas123 dbname=otus'
otus-# PUBLICATION pub_test WITH (copy_data = true);
NOTICE:  created replication slot "sub_test" on publisher
CREATE SUBSCRIPTION
```

### Выполняем настройку для `vm3`

Переходим в терминал PostgreSQL:
```
vagrant@vm3:~$ sudo -u postgres psql
psql (12.10 (Ubuntu 12.10-0ubuntu0.20.04.1))
Type "help" for help.
```

Переключаемся на БД `otus`:
```
postgres=# \c otus
You are now connected to database "otus" as user "postgres".
```

Выполняем подписку на таблицу `test`:
```
otus=# CREATE SUBSCRIPTION sub_test3
otus-# CONNECTION 'host=192.168.255.1 port=5432 user=otususer password=pas123 dbname=otus'
otus-# PUBLICATION pub_test WITH (copy_data = true);
NOTICE:  created replication slot "sub_test3" on publisher
CREATE SUBSCRIPTION
```

Выполняем подписку на таблицу `test2`:
```
otus=# CREATE SUBSCRIPTION sub_test4
otus-# CONNECTION 'host=192.168.255.2 port=5432 user=otususer password=pas123 dbname=otus'
otus-# PUBLICATION pub_test2 WITH (copy_data = true);
NOTICE:  created replication slot "sub_test4" on publisher
CREATE SUBSCRIPTION
```

### Выполняем настройку для `vm4`

Останавливаем кластер:
```bash
sudo pg_ctlcluster 12 main stop
```

Удалим данные для остановленного кластера:
```bash
sudo rm -rf /var/lib/postgresql/12/main
```

Настроим бэкап (пароль `pas123`):
```bash
sudo -u postgres pg_basebackup -h 192.168.255.3 -p 5432 -U otususer -R -D /var/lib/postgresql/12/main
```

Запустим кластер:
```bash
sudo pg_ctlcluster 12 main start
```

### Проверка

Подключимся к `vm1` и вставим данные в таблицу `test`:

```sql
INSERT INTO test SELECT generate_series(1,10), md5(random()::text)::char(10);
```

Затем подключимся к `vm2` и вставим данные в таблицу `test2`:

```sql
INSERT INTO test2 SELECT generate_series(1,10), md5(random()::text)::char(10);
```

Проверим наличие записей на каждой ВМ:

```sql
otus=# SELECT * FROM test;
 id |    name    
----+------------
  1 | e04597e3c3
  2 | dcbb7c2892
  3 | 1c56d2a2e0
  4 | 2b8eaa2e90
  5 | a1bcc00f8c
  6 | cb673a9dee
  7 | c52c859fd5
  8 | 31ff0cdab1
  9 | 2345d0ea28
 10 | 8f4d2f34a8
(10 rows)
```

```sql
otus=# SELECT * FROM test2;
 id |    name    
----+------------
  1 | 80d4f7ea42
  2 | bd461c1da8
  3 | 5fc6a6171f
  4 | eef3abb683
  5 | e087db5ab9
  6 | b9c5643a4a
  7 | 134fc755e2
  8 | a3730aebbd
  9 | dea4cfb6fd
 10 | de4860d877
(10 rows)
```
