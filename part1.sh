#!/bin/bash
echo "\033[33mConfiguration of the UNIX OS Ubuntu 18.4\033[0m"
echo "\033[33mYOU MUST BE ROOT TO PERFORM THIS OPERATION\033[0m"
echo"\033[31mPlease enter your personal username:\033[0m"
read PERSO
read -p "Configuration for $PERSO, press enter"
sudo adduser $PERSO
# update system
echo "\033[33mAPT update/upgrade & installation of required packages\033[0m"
apt-get update && apt-get upgrade -y
echo "\033[33mInstsallation of required packages\033[0m"
apt-get install -y vim net-tools ufw fail2ban portsentry ssmtp mailutils nginx openssl curl
echo "\033[33mUpgrading and config vim\033[0m"
apt-get upgrade -y vim
echo"set nu\nsyntax on\nset mouse=a\ncolo torte\n" > ~/.vimrc

# create sudo user
echo "\033[33mAdding your username to sudo group\033[0m"
adduser $PERSO sudo

# set static ip according to the v-host
echo "\033[33mSetting up netplan...\033[0m"
cp config/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml
chmod 644 /etc/netplan/50-cloud-init.yaml

# Change SSH port
echo "\033[33mSSH configuration:\033[0m"
echo "\033[33mUncomment '# Port 22' on line 13: change the number to 2223\033[0m"
read -p "Press enter to edit the config file"
vim /etc/ssh/sshd_config
service ssh restart

# UFW
echo "\033[33mSetting up UFW firewall...\033[0m"
ufw default deny incoming
ufw default allow outgoing
ufw allow 2223/tcp
ufw enable
echo "\033[33mUFW firewall status\033[0m"
ufw status

# Fail2ban
echo "\033[33mSetting up Fail2ban...\033[0m"
cp config/jail.local /etc/fail2ban/
chmod 644 /etc/fail2ban/jail.local
echo "\033[33mReload Fail2ban configuration\033[0m"
fail2ban-client reload
echo "\033[33mFail2ban status\033[0m"
service status fail2ban

# for ports scan
echo "\033[33mSetting up default/portsentry...\033[0m"
cp config/portsentry /etc/default/portsentry
chmod 644 /etc/default/portsentry
echo "\033[33mSetting up portsentry.conf\033[0m"
chmod 644 /etc/portsentry/portsentry.conf
echo "\033[33mReload Portsentry configuration\033[0m"
service portsentry restart
echo "\033[Portsentry status\033[0m"
service status portsentry

# configure mail to root
echo "\033[33mSetting up root emails\033[0m"
echo "\033[33mConfigure /etc/ssmtp/revaliases...\033[0m"
echo "root:brooks29@ethereal.email:smtp.ethereal.email:587" >> /etc/ssmtp/revaliases
echo "\033[33mConfigure /etc/ssmtp/ssmtp.conf...\033[0m"
cp config/ssmtp.conf /etc/ssmtp/ssmtp.conf
chmod 640 /etc/ssmtp/ssmtp.conf

# setup crontab and scripts
echo "\033[33mSetting up cron scripts\033[0m"
cp -R scripts /etc/cron.d/
chmod +x /etc/cron.d/scripts/*
#write out current crontab
crontab -l > mycron
#echo new cron into cron file
# Mise a jour au redemarrage
echo "0 4 * * 1 sh /etc/cron.d/scripts/packages.sh" >> mycron
echo "@reboot sh /etc/cron.d/scripts/packages.sh" >> mycron
# Alerte en cas de modification de crontab
echo "0 0 * * * /etc/cron.d/scripts/survey.sh" >> mycron
#install new cron file
crontab mycron
rm mycron

echo "\033[33mAutomatic configuration done\033[0m"
echo "\033[33m\n\nPlease complete the SSH configuration for the public key authentication by following those guidelines.\n\033[0m"
echo "-- run the command without the $ --
On host:
$ ssh-keygen
$ ssh-copy-id $PERSO@192.168.56.2
or copy the key manually into ~/.ssh/Authorized_keys file
[that hostname is corresponding to our setup]"
ip a | grep enp0s8| grep inet
echo "When it's done, to enable ssh public key login, edit /etc/ssh/sshd_config file
$ sudo vim /etc/ssh/sshd_config
uncomment and change those lines
  #PubkeyAuthentication yes
  #AuthorizedKeysFile .ssh/authorized_keys
  #PermitRootLogin no
  #PasswordAuthentication no
then Restart service
$ sudo service ssh restart
You can now connect to remote-host via ssh by typing
$ $PERSO@192.168.56.2 -p2223
"

echo "\033[33mOn Then reboot, stop undesired services (you can see which one are running typing)
$ service --status-all
and execute part2.sh !/30\033[0m"
