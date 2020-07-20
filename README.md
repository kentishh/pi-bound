# Pi-Bound installs and configures PiHole and Unbound to be your network's recursive DNS server.

A simple script that installs PiHole, then automatically installs and configures Unbound to be your pihole's DNS server.

This script supports IPv4 as well as IPv6, you will be prompted during the script for your required configuration.

## How to run

Run the following command on your Pi to download the script:

```
wget -O pi-bound.sh https://raw.githubusercontent.com/kentishh/pihole_unbound/master/pi-bound.sh
chmod +x pi-bound.sh
sudo ./pi-bound.sh
```
## Final steps

Some DNS checks are completed after the install which will be printed to the screen depending on if they came back successful or not. As long as these tests come back without any errors, you can then alter your DHCP settings to point to the IP of your PI. Otherwise, point your devices manually to use your Pi as your DNS server.
