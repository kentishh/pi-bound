# PiHole and Unbound DNS (with DNSSEC) setup

A simple script that installs PiHole, then automatically installs and configures Unbound to be your pihole's DNS server.

This script supports IPv4 as well as IPv6, you will be prompted during the script for your required configuration.

## How to run

Run the following command on your Pi to download the script:

```
wget -O pihole-unbound.sh https://raw.githubusercontent.com/kentishh/pihole_unbound/master/pihole-unbound.sh
chmod +x pihole-unbound.sh
sudo ./pihole-unbound.sh
```
## Final steps

Some DNS checks are completed after the install which will be printed to the screen depending on if they came back successful or not. As long as these tests come back without any errors, you can then alter your DHCP settings to point to the IP of your PI. Otherwise, point your devices manually to use your Pi as your DNS server.
