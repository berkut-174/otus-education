# Практика с SELinux

## Задание

1. Запустить nginx на нестандартном порту 3-мя разными способами:

   - переключатели setsebool;
   - добавление нестандартного порта в имеющийся тип;
   - формирование и установка модуля SELinux.

    К сдаче:

    - README с описанием каждого решения (скриншоты и демонстрация приветствуются).

2. Обеспечить работоспособность приложения при включенном selinux.

   - развернуть приложенный стенд https://github.com/mbfx/otus-linux-adm/tree/master/selinux_dns_problems;
   - выяснить причину неработоспособности механизма обновления зоны (см. README);
   - предложить решение (или решения) для данной проблемы;
   - выбрать одно из решений для реализации, предварительно обосновав выбор;
   - реализовать выбранное решение и продемонстрировать его работоспособность.

    К сдаче:

    - README с анализом причины неработоспособности, возможными способами решения и обоснованием выбора одного из них;
    - исправленный стенд или демонстрация работоспособной системы скриншотами и описанием.

## Структура стенда

`Vagrantfile` — файл базовой конфигурации виртуального стенда

`provisioning/*`, `client.sh` и `ns01.sh` — дополнительные файлы для настройки стенда

## Решение

1. Первоначальное состояние стенда представлено на скриншоте: в конфигурации nginx используется нестандартный порт 4881,
синтаксис nginx корректный, брандмауэр выключен, SELinux включен, при этом служба nginx не запускается.

   ![01](https://user-images.githubusercontent.com/1829509/154211684-452bd4ff-a11f-43e4-bb64-23baa788989e.png)

   Проверим содержимое файла лога `/var/log/audit/audit.log`. В нём присутствуют ошибки, указывающие на нестандартный порт 4881.

   ![02](https://user-images.githubusercontent.com/1829509/154211693-de93f7f4-28d3-4d5e-a81a-c3caeaa1aa8a.png)

   Исправим это с помощью переключателя `setsebool`.

   ![03](https://user-images.githubusercontent.com/1829509/154211699-8ee6580c-0877-4b70-b5c5-503819ba83a4.png)

   Исправим это, добавив нестандартный порт в имеющийся тип.

   ![04](https://user-images.githubusercontent.com/1829509/154211704-49657dd6-0f70-4dff-8fae-5a66ec9c4368.png)

   Исправим это, сформировав и установив свой модуль SELinux.

   ![05](https://user-images.githubusercontent.com/1829509/154211706-59d5c6eb-5afc-4a58-aad0-0025a3205c39.png)


2. Поиск возможных причин неработоспособности обновления зоны выполнялся в следующем порядке:
   - на ВМ с именем `client` был изучен файл лога `/var/log/audit/audit.log`, ошибок он не содержал, всё было в порядке
   - на ВМ с именем `ns01` были следующие ошибки:
     ```
     [root@ns01 ~]# cat /var/log/audit/audit.log | audit2why
     type=AVC msg=audit(1644987692.135:2020): avc:  denied  { create } for  pid=5291 comm="isc-worker0000" name="named.ddns.lab.view1.jnl" scontext=system_u:system_r:named_t:s0 tcontext=system_u:object_r:etc_t:s0 tclass=file permissive=0

             Was caused by:
                     Missing type enforcement (TE) allow rule.

                     You can use audit2allow to generate a loadable module to allow this access.

     ```
     ```
     [root@ns01 ~]# aureport -a

      AVC Report
      ===============================================================
      # date time comm subj syscall class permission obj result event
      ===============================================================
      1. 02/16/22 04:57:26 ? system_u:system_r:system_dbusd_t:s0-s0:c0.c1023 0 (null) (null) (null) unset 1175
      2. 02/16/22 04:57:29 ? system_u:system_r:system_dbusd_t:s0-s0:c0.c1023 0 (null) (null) (null) unset 1177
      3. 02/16/22 05:01:32 isc-worker0000 system_u:system_r:named_t:s0 2 file create system_u:object_r:etc_t:s0 denied 2020
     ```
     ```
     [root@ns01 ~]# journalctl -p err /sbin/named
     -- Logs begin at Wed 2022-02-16 04:56:07 UTC, end at Wed 2022-02-16 05:11:13 UTC. --
     Feb 16 05:01:32 ns01 named[5291]: /etc/named/dynamic/named.ddns.lab.view1.jnl: create: permission denied
     ```

   Проверим права на каталог `/etc/named`, для которого есть ошибки в логах:
     ```
     [root@ns01 ~]# ls -RZ /etc/named
     /etc/named:
     drw-rwx---. root named unconfined_u:object_r:etc_t:s0   dynamic
     -rw-rw----. root named system_u:object_r:etc_t:s0       named.50.168.192.rev
     -rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab
     -rw-rw----. root named system_u:object_r:etc_t:s0       named.dns.lab.view1
     -rw-rw----. root named system_u:object_r:etc_t:s0       named.newdns.lab

     /etc/named/dynamic:
     -rw-rw----. named named system_u:object_r:etc_t:s0       named.ddns.lab
     -rw-rw----. named named system_u:object_r:etc_t:s0       named.ddns.lab.view1
     ```

   Из полученной информации следует, что необходимо установить корректный контекст безопасности для каталога `/etc/named/dynamic`.
   Проверим каким он должен быть:
   ```
   [root@ns01 ~]# semanage fcontext -l | grep dynamic
   /var/named/dynamic(/.*)?                           all files          system_u:object_r:named_cache_t:s0
   /var/named/chroot/var/named/dynamic(/.*)?          all files          system_u:object_r:named_cache_t:s0
   ```
   В выводе отсутствуют сведения о расположение `/etc/named/dynamic`, но у аналогичных каталогов в `/var`
   контекст безопасности равен `named_cache_t`.

   Поэтому добавим контекст в конфигурацию SELinux, такой метод является предпочтительным, так как позволит
   сохранить контекст безопасности при перезапуске системы.
   ```
   [root@ns01 ~]# semanage fcontext -a -t named_cache_t "/etc/named/dynamic(/.*)?"
   ```

   Затем восстановим дефолтный контекст безопасности для каталога `/etc/named/dynamic`:
   ```
   [root@ns01 ~]# restorecon -v -R /etc/named/dynamic
   restorecon reset /etc/named/dynamic context unconfined_u:object_r:etc_t:s0->unconfined_u:object_r:named_cache_t:s0
   restorecon reset /etc/named/dynamic/named.ddns.lab context system_u:object_r:etc_t:s0->system_u:object_r:named_cache_t:s0
   restorecon reset /etc/named/dynamic/named.ddns.lab.view1 context system_u:object_r:etc_t:s0->system_u:object_r:named_cache_t:s0
   ```

   После этого обновление зоны работает корректно.

   Эти изменения также внесены в конфигурацию стенда.
