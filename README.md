# 42_roger_skyline1
This is a project from Ecole 42

REQUIRED SET UP

ubuntu_server_18.04 VM
partitioned:
4.2Go /
2.2Go SWAP
1.986Go /home

-- run the command without the $ --
$ shutdown now

BEFORE TO PROCEED TO THE SERVER SET UP

On VirtualBox: setup a fixed IP with a subnet-netmask
- Go to File > Host network manager
- Create a Vboxnet#, disabled DHCP checkbox and set iPv4 Network Mask to 255.255.255.252
[the simplest way - the fixed ip set should be 192.168.56.1]
- In VB settings of this vm: Settings > Network > adapter 2 > check 'enable network adapter' and chose the Vboxnet# you just created

Then turn on the VM
YOU MUST BE ROOT TO RUN THE SCRIPTS
-- without the $, run command --
$ sudo -i
then type
$ git clone https://github.com/Ezouz/42_roger_skyline1.git
$ cd 42_roger_skyline1
and run
$ sh deploy.sh

--------

In case of you turn of the vm and need the script to proceed to the last step:
  Please complete the SSH configuration for the public key authentication by following those guidelines.

  On host:
  first, connect via ssh
  $ username@192.168.56.2 -p2223
 "
  The authenticity of host '[192.168.56.2]:2223 ([192.168.56.2]:2223)' can't be established.
  ECDSA key fingerprint is SHA256:UgOFJlwoyFrGIeUo3lcTfV9d4HGL6PPOf+/RgYRcLXg.
  Are you sure you want to continue connecting (yes/no)?
  Warning: Permanently added '[192.168.56.2]:2223' (ECDSA) to the list of known hosts.
 "
  type yes and your password

  $ ssh-keygen
  Enter a passphrase you will memorize

  $ ssh-copy-id username@192.168.56.2
  or copy the key manually into ~/.ssh/Authorized_keys file

  [that hostname is corresponding to our setup, run
  $ ip a | grep enp0s8| grep inet
  if you want to check]

  When it's done, to enable ssh public key username, edit /etc/ssh/sshd_config file
  On vm:

  $ sudo vim /etc/ssh/sshd_config
  uncomment and change those lines

  #PubkeyAuthentication yes
  #AuthorizedKeysFile .ssh/authorized_keys
  #PermitRootLogin no
  #PasswordAuthentication no

  then Restart service
  $ sudo service ssh restart

  You can now connect to remote-host via ssh by typing
  $ username@192.168.56.2 -p2223

  Enter your passphrase and the public keys authentication has worked !
