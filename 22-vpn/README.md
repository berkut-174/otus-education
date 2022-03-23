# VPN

## Задание

1. Между двумя виртуалками поднять vpn в режимах
    - tun;
    - tap.
2. Поднять RAS на базе OpenVPN с клиентскими сертификатами, подключиться с локальной машины на виртуалку.
3. *Самостоятельно изучить, поднять ocserv и подключиться с хоста к виртуалке

Формат сдачи ДЗ — vagrant + ansible.

## Структура стенда

`Vagrantfile` — файл базовой конфигурации виртуального стенда

`provisioning/*` — файлы конфигурации для настройки стенда с помощью ansible

## Решение

Запуск стенда: `vagrant up`

1. Замеры скорости в туннели:

   - TAP

   ```
   [root@server ~]# iperf3 -s
   -----------------------------------------------------------
   Server listening on 5201
   -----------------------------------------------------------
   Accepted connection from 10.10.10.2, port 42838
   [  5] local 10.10.10.1 port 5201 connected to 10.10.10.2 port 42840
   [ ID] Interval           Transfer     Bandwidth
   [  5]   0.00-1.00   sec  22.1 MBytes   185 Mbits/sec
   [  5]   1.00-2.00   sec  23.1 MBytes   194 Mbits/sec
   [  5]   2.00-3.00   sec  25.8 MBytes   216 Mbits/sec
   ...
   [  5]  40.00-40.10  sec  1.58 MBytes   139 Mbits/sec
   - - - - - - - - - - - - - - - - - - - - - - - - -
   [ ID] Interval           Transfer     Bandwidth
   [  5]   0.00-40.10  sec  0.00 Bytes  0.00 bits/sec                  sender
   [  5]   0.00-40.10  sec   972 MBytes   203 Mbits/sec                  receiver
   ```

   ```
   [root@client ~]# iperf3 -c 10.10.10.1 -t 40 -i 5
   Connecting to host 10.10.10.1, port 5201
   [  4] local 10.10.10.2 port 42840 connected to 10.10.10.1 port 5201
   [ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
   [  4]   0.00-5.01   sec   125 MBytes   210 Mbits/sec   64    886 KBytes
   [  4]   5.01-10.00  sec   122 MBytes   205 Mbits/sec  114    575 KBytes
   [  4]  10.00-15.01  sec   125 MBytes   209 Mbits/sec   18    547 KBytes
   [  4]  15.01-20.00  sec   121 MBytes   203 Mbits/sec    0    686 KBytes
   [  4]  20.00-25.00  sec   130 MBytes   218 Mbits/sec    0    808 KBytes
   [  4]  25.00-30.00  sec   122 MBytes   205 Mbits/sec    6    974 KBytes
   [  4]  30.00-35.00  sec   123 MBytes   207 Mbits/sec    4    937 KBytes
   [  4]  35.00-40.00  sec   106 MBytes   178 Mbits/sec  179    739 KBytes
   - - - - - - - - - - - - - - - - - - - - - - - - -
   [ ID] Interval           Transfer     Bandwidth       Retr
   [  4]   0.00-40.00  sec   974 MBytes   204 Mbits/sec  385             sender
   [  4]   0.00-40.00  sec   972 MBytes   204 Mbits/sec                  receiver

   iperf Done.
   ```

   - TUN

   ```
   [root@server ~]# iperf3 -s
   -----------------------------------------------------------
   Server listening on 5201
   -----------------------------------------------------------
   Accepted connection from 10.10.10.2, port 42842
   [  5] local 10.10.10.1 port 5201 connected to 10.10.10.2 port 42844
   [ ID] Interval           Transfer     Bandwidth
   [  5]   0.00-1.00   sec  22.7 MBytes   191 Mbits/sec
   [  5]   1.00-2.00   sec  27.4 MBytes   230 Mbits/sec
   [  5]   2.00-3.00   sec  26.8 MBytes   225 Mbits/sec
   ...
   [  5]  40.00-40.10  sec  2.01 MBytes   173 Mbits/sec
   - - - - - - - - - - - - - - - - - - - - - - - - -
   [ ID] Interval           Transfer     Bandwidth
   [  5]   0.00-40.10  sec  0.00 Bytes  0.00 bits/sec                  sender
   [  5]   0.00-40.10  sec  1.06 GBytes   227 Mbits/sec                  receiver
   ```

   ```
   [root@client ~]# iperf3 -c 10.10.10.1 -t 40 -i 5
   Connecting to host 10.10.10.1, port 5201
   [  4] local 10.10.10.2 port 42844 connected to 10.10.10.1 port 5201
   [ ID] Interval           Transfer     Bandwidth       Retr  Cwnd
   [  4]   0.00-5.01   sec   137 MBytes   230 Mbits/sec  162    521 KBytes
   [  4]   5.01-10.01  sec   139 MBytes   233 Mbits/sec    5    532 KBytes
   [  4]  10.01-15.00  sec   139 MBytes   233 Mbits/sec    2    502 KBytes
   [  4]  15.00-20.00  sec   136 MBytes   228 Mbits/sec    1    505 KBytes
   [  4]  20.00-25.00  sec   137 MBytes   229 Mbits/sec    0    646 KBytes
   [  4]  25.00-30.00  sec   134 MBytes   225 Mbits/sec  106    469 KBytes
   [  4]  30.00-35.00  sec   136 MBytes   229 Mbits/sec    0    643 KBytes
   [  4]  35.00-40.00  sec   131 MBytes   220 Mbits/sec    2    642 KBytes
   - - - - - - - - - - - - - - - - - - - - - - - - -
   [ ID] Interval           Transfer     Bandwidth       Retr
   [  4]   0.00-40.00  sec  1.06 GBytes   228 Mbits/sec  278             sender
   [  4]   0.00-40.00  sec  1.06 GBytes   228 Mbits/sec                  receiver

   iperf Done.
   ```

   Пропускная способность TUN, согласно полученным данным, оказалась чуть выше.

2. RAS на базе OpenVPN: `vagrant ssh ras`

   С этой ВМ необходимо скопировать каталог `/etc/openvpn/client` на хостовую машину. Затем на хостовой машине перейти в этот каталог и выполнить для подключения к VPN серверу:

   ```
   [root@mypc client]# openvpn --config client.conf
   Wed Mar 23 10:50:23 2022 WARNING: file './client.key' is group or others accessible
   Wed Mar 23 10:50:23 2022 OpenVPN 2.4.9 x86_64-alt-linux-gnu [SSL (OpenSSL)] [LZO] [LZ4] [EPOLL] [PKCS11] [MH/PKTINFO] [AEAD] built on Nov 17 2020
   Wed Mar 23 10:50:23 2022 library versions: OpenSSL 1.1.1l  24 Aug 2021, LZO 2.10
   Wed Mar 23 10:50:23 2022 WARNING: No server certificate verification method has been enabled.  See http://openvpn.net/howto.html#mitm for more info.
   Wed Mar 23 10:50:23 2022 TCP/UDP: Preserving recently used remote address: [AF_INET]192.168.10.30:1207
   Wed Mar 23 10:50:23 2022 Socket Buffers: R=[212992->212992] S=[212992->212992]
   Wed Mar 23 10:50:23 2022 UDP link local (bound): [AF_INET][undef]:1194
   Wed Mar 23 10:50:23 2022 UDP link remote: [AF_INET]192.168.10.30:1207
   Wed Mar 23 10:50:23 2022 TLS: Initial packet from [AF_INET]192.168.10.30:1207, sid=98e943bd f6c85a51
   Wed Mar 23 10:50:23 2022 VERIFY OK: depth=1, CN=rasvpn
   Wed Mar 23 10:50:23 2022 VERIFY OK: depth=0, CN=rasvpn
   Wed Mar 23 10:50:23 2022 Control Channel: TLSv1.2, cipher TLSv1.2 ECDHE-RSA-AES256-GCM-SHA384, 2048 bit RSA
   Wed Mar 23 10:50:23 2022 [rasvpn] Peer Connection Initiated with [AF_INET]192.168.10.30:1207
   Wed Mar 23 10:50:24 2022 SENT CONTROL [rasvpn]: 'PUSH_REQUEST' (status=1)
   Wed Mar 23 10:50:24 2022 PUSH: Received control message: 'PUSH_REPLY,route 10.10.10.0 255.255.255.0,topology net30,ping 10,ping-restart 120,ifconfig 10.10.10.6 10.10.10.5,peer-id 0,cipher AES-256-GCM'
   Wed Mar 23 10:50:24 2022 OPTIONS IMPORT: timers and/or timeouts modified
   Wed Mar 23 10:50:24 2022 OPTIONS IMPORT: --ifconfig/up options modified
   Wed Mar 23 10:50:24 2022 OPTIONS IMPORT: route options modified
   Wed Mar 23 10:50:24 2022 OPTIONS IMPORT: peer-id set
   Wed Mar 23 10:50:24 2022 OPTIONS IMPORT: adjusting link_mtu to 1625
   Wed Mar 23 10:50:24 2022 OPTIONS IMPORT: data channel crypto options modified
   Wed Mar 23 10:50:24 2022 Data Channel: using negotiated cipher 'AES-256-GCM'
   Wed Mar 23 10:50:24 2022 Outgoing Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
   Wed Mar 23 10:50:24 2022 Incoming Data Channel: Cipher 'AES-256-GCM' initialized with 256 bit key
   Wed Mar 23 10:50:24 2022 ROUTE_GATEWAY 192.168.51.1/255.255.255.0 IFACE=wlp0s20f3 HWADDR=08:a1:55:61:78:99
   Wed Mar 23 10:50:24 2022 TUN/TAP device tun0 opened
   Wed Mar 23 10:50:24 2022 TUN/TAP TX queue length set to 100
   Wed Mar 23 10:50:24 2022 /usr/bin/ip link set dev tun0 up mtu 1500
   Wed Mar 23 10:50:24 2022 /usr/bin/ip addr add dev tun0 local 10.10.10.6 peer 10.10.10.5
   Wed Mar 23 10:50:24 2022 /usr/bin/ip route add 192.168.10.0/24 via 10.10.10.5
   RTNETLINK answers: File exists
   Wed Mar 23 10:50:24 2022 ERROR: Linux route add command failed: external program exited with error status: 2
   Wed Mar 23 10:50:24 2022 /usr/bin/ip route add 10.10.10.0/24 via 10.10.10.5
   Wed Mar 23 10:50:24 2022 WARNING: this configuration may cache passwords in memory -- use the auth-nocache option to prevent this
   Wed Mar 23 10:50:24 2022 Initialization Sequence Completed
   ```
