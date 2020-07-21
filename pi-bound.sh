#!/bin/bash


# Let's check the script is being run as root

if [[ $EUID -ne 0 ]] ; then
	echo "This script must be run as root to continue, either sudo this script or run under the root account"
	exit 1
fi


# This function just checks to see if a command is present. This is used to assume the distro we are running.
is_command() {
	local check_command="$1"

	command -v "${check_command}" > /dev/null 2>&1
}


# Main install function, this installs pihole, unbound and wget which we use to get some config files
install() {
	if is_command apt-get ; then
		tput setaf 2; echo "Running Debian based distro, continuing..."
		tput setaf 2; echo "PiHole installation beginning..."
		curl -sSL https://install.pi-hole.net | bash
	else
		tput setaf 1; echo "This script needs has been written to run on Debian based distros. Quiting..."
		exit 1
	fi
}

installdns() {
	if is_command apt-get; then
		# Install unbound and wget
		tput setaf 2; echo "Updating repositories..."
		apt update -y > /dev/null 
		tput setaf 2; echo "Installing unbound and wget..."
	       	apt install unbound wget -y > /dev/null
	
	else
		tput setaf 1; echo "This script needs has been written to run on Debian based distros. Quiting..."
		exit 1
	fi
}

configure() {

	# Get root hints file and move into unbound install directory
	tput setaf 2; echo "Getting root hints for unbound..."
	if is_command wget ; then
		wget -O /var/lib/unbound/root.hints https://www.internic.net/domain/named.root 
	else
		tput setaf 1; echo "wget is not installed, please install wget and try to run the script again"
		exit 1
	fi

	# Create a monthly cronjob to get root hints
	tput setaf 2; echo "Creating cron job to get root hints on a monthly basis..."
	(crontab -l 2>/dev/null; echo "0 0 1 * * wget -O /var/lib/unbound/root.hints https://www.internic.net/domain/named.root") | crontab -

	# Ask user for ipv4 or ipv6 configuration file for unbound
	read -p "Do you want unbound to resolve IPv6 addresses? (Y/N)" network
	if $network -eq "N" ; then
		wget -O /etc/unbound/unbound.conf.d/pi-hole.conf https://raw.githubusercontent.com/kentishh/pihole_unbound/master/unbound-ipv4 
	else
		wget -O /etc/unbound/unbound.conf.d/pi-hole.conf https://raw.githubusercontent.com/kentishh/pihole_unbound/master/unbound-ipv6 

	fi

	# Start and enable unbound service
	tput setaf 2; echo "Starting Unbound..."
	systemctl start unbound

  	tput setaf 2; echo "Enabling Unbound to start at boot..."	
	systemctl enable unbound

	# Alter pihole DNS options
	sed -i 's/PIHOLE_DNS_1=.*$/PIHOLE_DNS_1=127.0.0.1#5335/' "/etc/pihole/setupVars.conf"
	sed -i '/PIHOLE_DNS_2=.*$/d' "/etc/pihole/setupVars.conf"	
}

dns() {

	# Some variables for testing DNS lookups
	servfail=$(dig sigfail.verteiltesysteme.net @127.0.0.1 -p 5335 | grep SERVFAIL)
	noerror=$(dig sigok.verteiltesysteme.net @127.0.0.1 -p 5335 | grep NOERROR)

	if [[ $servfail == *"SERVFAIL"* ]]; then
		tput setaf 2; echo "First DNS test completed successfully."
	else
		tput setaf 1; echo "First DNS query returned unexpected result."
	fi

	if [[ $noerror == *"NOERROR"* ]]; then
		tput setaf 2; echo "Second DNS test completed successfully."
	else
		tput setaf 1; echo " Second DNS query returned unexpected result."
	fi
}


echo "This script will install pihole, unbound and automatically configure your pihole DNS configuration to use unbound."
printf "What would you like to do? (enter a number and press enter) \n1) Install Pihole and unbound along with required configuration.\n2) Install unbound along with required configuration.\n"

read answer

if [ "$answer" == "1" ] ;then
	install
	installdns
	configure
	dns
else
	installdns
	configure
	dns
fi
