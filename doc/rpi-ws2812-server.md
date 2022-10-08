# RPI-WS2812-Server

[RPI-WS2812-Server](https://github.com/tom-2015/rpi-ws2812-server) is used to controll the LEDs on the Raspberry Pi.

## Software Setup

1. Follow the [installation guide](https://github.com/tom-2015/rpi-ws2812-server#installation)
  * Note: The `sed` command to disable audio does not work, so open `/boot/config.txt` in vim and manually comment the `tparam=audio=on` line out with a leading `#`
  * Reboot the Raspberry Pi
1. [Setup running as a service](https://github.com/tom-2015/rpi-ws2812-server#running-as-a-service)
  * If the install fails because the service is not running, open `makefile` and remove the line `systemctl stop ws2812svr.service` in `install`
  * For use with the Elixir OSC Server, we're going to use the `tcp` mode (default) with port `9999` (default)

## RPI Tuning

* Disable IPV6
  * It seems like IPV6 might cause problems 
  * https://github.com/tom-2015/rpi-ws2812-server/issues/25
  * https://www.howtoraspberry.com/2020/04/disable-ipv6-on-raspberry-pi/

## Configuration

* The NeoPixel RGB Rings are GRB, so `led_type=3` 

## Testing

Once the server is running in `tcp`-mode, you can use [netcat](https://de.wikipedia.org/wiki/Netcat) to send commands via tcp, either via SSH on the Pi, or from any other device in your network.

## Example

* `setup 1,32,3`
* `init`
* `fill 1,ff0000`
* `render`