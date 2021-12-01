# Попасть в систему без пароля несколькими способами

## Меню grub

![Screenshot_sandbox_centos8_2021-12-01_09:44:18](https://user-images.githubusercontent.com/1829509/144187921-8d16933f-9928-4ce9-9a74-330b1f290446.png)

## Вход с помощью `init=/bin/sh`

![Screenshot_sandbox_centos8_2021-12-01_09:48:38](https://user-images.githubusercontent.com/1829509/144187930-78be0602-1b75-4e71-89a5-1ce647184e46.png)

![Screenshot_sandbox_centos8_2021-12-01_09:49:22](https://user-images.githubusercontent.com/1829509/144187932-deea77e1-b9f2-4f5d-a70a-39b778a9610a.png)

## Вход с помощью `rd.break`

![Screenshot_sandbox_centos8_2021-12-01_09:49:46](https://user-images.githubusercontent.com/1829509/144187939-5b0831fb-825d-4906-ae57-836da05d37b2.png)

![Screenshot_sandbox_centos8_2021-12-01_09:54:33](https://user-images.githubusercontent.com/1829509/144187947-bbed3302-a56f-44d5-ab1d-ca317014e6d2.png)

## Вход с помощью `rw init=/sysroot/bin/sh`

![Screenshot_sandbox_centos8_2021-12-01_09:55:26](https://user-images.githubusercontent.com/1829509/144187953-f3e0a7a8-7a2a-4900-b8a4-5e7de0108e11.png)

![Screenshot_sandbox_centos8_2021-12-01_09:55:53](https://user-images.githubusercontent.com/1829509/144187956-0cf6abfc-2b02-45c1-aaee-fe25e18451c8.png)

## Описание разных способов

`init=/bin/sh`,  `init=/sysroot/bin/sh` — сообщает ядру запустить в качестве init процесса оболочку `bash`
`rd.break` — выполняет аналогичную операцию, только средствами инструмента `dracut`