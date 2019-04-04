# 42_roger_skyline1
This is a project from Ecole 42

Before to proceed
On VirtualBox: setup a fixed IP with a subnet-netmask

- Shutdown VM to do this last step
- Go to File > Host network manager
- Create a Vboxnet#, disabled DHCP checkbox and set iPv4 Network Mask to 255.255.255.252
[the simplest way - the fixed ip set should be 192.168.56.1]
- In VB settings of this vm: Settings > Network > adapter 2 > check 'enable network adapter' and chose the Vboxnet# you just created

git clone this repository in a ubuntu_server_18.04 VM
partitioned:
4.2Go /
2.2Go SWAP
1.986Go /home

YOU MUST BE ROOT TO RUN THE SCRIPTS
-- without the $, run command --
$ sudo -i
then type
$ git clone https://github.com/Ezouz/42_roger_skyline1.git
$ cd 42_roger_skyline1
and run
$ sh deploy.sh
