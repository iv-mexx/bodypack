# Elixir Server



## Setup

This has to run on the Raspberry Pi.

1. SSH into Raspberry Pi
1. Clone Repo

### Setup Ws2812-Server

1. It is included as a submodule, so `git submodule init && git submodule update`
1. Follow the Steps in [rpi-ws2812-server.md](./ws-2812-server.md)

## Setup Bodypack

1. Build Elixir Release
  * `./build.sh`
1. Setup as a service
  * Use the provided .service file: `cp bodypcak.service /etc/systemd/system/`
  * `sudo systemctl daemon-reload`
  * `sudo systemctl start bodypack.service`

### Deploy Update on Rasperry Pi

1. SSH into Raspberry Pi
1. Pull Repo
1. Build Elixir Release
  * `./build.sh`
1. Restart the Service or the whole Pi