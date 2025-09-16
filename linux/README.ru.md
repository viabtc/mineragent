# Руководство по развертыванию MinerAgent в Linux (Ubuntu)

Русский | [简体中文](./README.md) | [English](./README.en.md)

## Системные требования:
- Операционная система (ОС): Ubuntu Server 22.04 x86_64 или новее
- Процессор: 4 ядра и более
- Оперативная память (ОЗУ): 8 ГБ и более
- Диск: 60 ГБ и более
## Этапы развертывания
Все команды выполняются в `Терминале`.
### 1. Подготовка среды
Перед началом развертывания MinerAgent необходимо установить зависимости, выполнив следующие команды:
```bash
sudo apt update
sudo apt install -y jq unzip wget
```

### 2. Загрузка MinerAgent
При необходимости перейдите в папку установки с помощью команды `cd`. В данном руководстве в качестве места установки используется папка по умолчанию (`cd ~`).   
Выполните следующую команду для загрузки MinerAgent: 
```bash
wget https://download.viabtc.top/viabtc_mineragent.zip
unzip viabtc_mineragent.zip
```
После загрузки перейдите в следующий каталог: 
```bash
cd mineragent-master/linux
```
### 3. Первоначальный запуск MinerAgent
Для первого запуска можно использовать скрипт `start.sh`, который запускает MinerAgent и автоматически настраивает cron для периодической проверки работы агента.  
**Пример запуска для конкретной монеты (`BTC` или `LTC`): **  
```bash
sudo ./start.sh btc
или
sudo ./start.sh ltc
```
**Расширенное использование (настраиваемый сервер майнинг-пула)**  
MinerAgent поддерживает настройку до трёх адресов сервера для майнинг-пула.  
Формат адреса сервера: `host:port:[ssl|nossl]`
- `host` — адрес сервера пула (например, `btc.viabtc.com`)
- `port` — порт сервера (например, `3333`)
- `[ssl|nossl]` — использовать SSL (ssl) или нет (nossl)
  
**Пример:**  
Запуск агента BTC с конфигурацией двух серверов для майнинг- пула:
```bash
sudo ./start.sh btc btc.viabtc.com:3333:nossl btc-ssl.viabtc.io:551:ssl
```
### 4. Подключение майнеров
Майнеры подключаются к MinerAgent через `IP:Port`.  
- IP` — адрес сервера, на котором запущен агент
- Порты по умолчанию (используйте только один порт из списка):
  - BTC: `3333, 443, 25`
  - LTC: `5555, 446, 26`

Проверка IP-адреса сервера:
```bash
ip -a
```
Вы получите вывод вида:
```bash
1: lo: <LOOPBACK,UP,LOWER_UP> mtu 65536 qdisc noqueue state UNKNOWN group default qlen 1000
    link/loopback 00:00:00:00:00:00 brd 00:00:00:00:00:00
    inet 127.0.0.1/8 scope host lo
       valid_lft forever preferred_lft forever
2: eth0: <BROADCAST,MULTICAST,UP,LOWER_UP> mtu 1500 qdisc fq_codel state UP group default qlen 1000
    link/ether 08:00:27:0e:63:9b brd ff:ff:ff:ff:ff:ff
    inet 192.168.1.100/24 brd 192.168.1.255 scope global dynamic noprefixroute eth0
       valid_lft 86311sec preferred_lft 86311sec
```
Найдите свой сетевой интерфейс, обычно это `eth0` (проводное соединение) или `wlan0` (беспроводное). В информации об интерфейсе обратите внимание на строку, начинающуюся с `inet`:  
`inet 192.168.1.100/24`  
Здесь `192.168.1.100` — IP-адрес вашего сервера.
Для настройки майнера укажите URL для майнинга BTC в формате: `stratum+tcp://192.168.1.100:3333`.

