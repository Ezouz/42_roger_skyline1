#!/bin/bash
echo "Configuration of the UNIX OS Ubuntu 18.4"
echo "YOU MUST BE ROOT TO PERFORM THIS OPERATION"
echo "Please enter your personal username:"
while ! [[ "$new_user" =~ ^[a-z]{2,20}$ ]] || [[ $new_user == '' ]]
do
    read -p 'username: ' new_user
    echo "associated regex: [a-z]{2,20}"
done
sudo adduser $new_user
# update system
echo "Update/upgrade & installation of required packages"
apt-get update && apt-get upgrade -y
echo "Instsallation of required packages"
apt-get install -y vim net-tools ufw fail2ban portsentry ssmtp mailutils nginx openssl curl
echo "Upgrading and config vim"
apt-get upgrade -y vim
echo"set nu\nsyntax on\nset mouse=a\ncolo torte\n" > ~/.vimrc

# create sudo user
echo "Adding your username to sudo group"
adduser $new_user sudo

# set static ip according to the v-host
echo "Setting up netplan..."
cp config/50-cloud-init.yaml /etc/netplan/50-cloud-init.yaml
chmod 644 /etc/netplan/50-cloud-init.yaml
netplan apply
# Change SSH port
echo "SSH configuration:"
echo "Uncomment '# Port 22' on line 13: change the number to 2223"
echo "then press escape and ':wq' to save and exit"
read -p 'Press enter to edit the config file'
vim /etc/ssh/sshd_config
service ssh restart

# UFW
echo "Setting up UFW firewall..."
ufw default deny incoming
ufw default allow outgoing
ufw allow 2223/tcp
ufw enable
ufw logging on
echo "UFW firewall status"
ufw status

# add filters and edit nginx.conf
# add limits.conf - which is included into nginx.conf http section
echo "Setting up nginx..."
cp config/limits.conf /etc/nginx/conf.d/limits.conf
chmod 644 /etc/nginx/conf.d/limits.conf
# Fail2ban conf Against DDOS, ports scanning and protect sshd
echo "Setting up Fail2ban..."
cp config/jail.local /etc/fail2ban/
chmod 644 /etc/fail2ban/jail.local
# fail2ban with UFW
cp config/ufw.conf /etc/fail2ban/action.d/ufw.conf
chmod 644 /etc/fail2ban/action.d/ufw.conf
# fail2ban filters
touch /var/log/ufwscanban.log
chmod 644 /var/log/ufwscanban.log
cp config/ufwscanban.conf /etc/fail2ban/filter.d/ufwscanban.conf
chmod 644 /etc/fail2ban/filter.d/ufwscanban.conf
cp config/nginx-http-400.conf /etc/fail2ban/filter.d/nginx-http-400.conf
chmod 644 /etc/fail2ban/filter.d/nginx-http-400.conf
cp config/nginx-http-403.conf /etc/fail2ban/filter.d/nginx-http-403.conf
chmod 644 /etc/fail2ban/filter.d/nginx-http-403.conf
cp config/nginx-http-408.conf /etc/fail2ban/filter.d/nginx-http-408.conf
chmod 644 /etc/fail2ban/filter.d/nginx-http-408.conf

# Portsentry conf
echo "Setting up portsentry"
cp config/portsentry /etc/default/portsentry
chmod 644 /etc/default/portsentry
cp config/portsentry.conf /etc/portsentry/portsentry.conf
chmod 644 /etc/portsentry/portsentry.conf

# configure mail to root
echo "Setting up root emails"
echo "Configure /etc/ssmtp/revaliases..."
echo "root:brooks29@ethereal.email:smtp.ethereal.email:587" >> /etc/ssmtp/revaliases
echo "Configure /etc/ssmtp/ssmtp.conf..."
cp config/ssmtp.conf /etc/ssmtp/ssmtp.conf
chmod 640 /etc/ssmtp/ssmtp.conf

# setup crontab and scripts
echo "Setting up cron scripts"
cp -R scripts /etc/cron.d/
chmod +x /etc/cron.d/scripts/*
#write out current crontab
crontab -l > mycron
#echo new cron into cron file
# Mise a jour au redemarrage
echo "0 4 * * 1 sh /etc/cron.d/scripts/packages.sh" >> mycron
echo "@reboot sh /etc/cron.d/scripts/packages.sh" >> mycron
# Alerte en cas de modification de crontab
echo "0 0 * * * sh /etc/cron.d/scripts/survey.sh" >> mycron
#install new cron file
crontab mycron
rm mycron

# UFW allow nginx
echo "Allow Nginx connections"
ufw allow 'Nginx Full'

# create ssl certificates
echo "Creating auto-signed ssl... Please fill the following form"
openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
echo "Creating dh group..."
openssl dhparam -out /etc/nginx/dhparam.pem 512

# create snippets
echo "Creating a file /etc/nginx/snippets/self-signed.conf..."
touch /etc/nginx/snippets/self-signed.conf
sh -c "echo 'ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;\nssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;' > /etc/nginx/snippets/self-signed.conf"

# cypher for ssl security
echo "Creating a file ssl-params.conf in /etc/nginx/snippets/..."
cp config/ssl-params.conf /etc/nginx/snippets/
chmod 644 /etc/nginx/snippets/ssl-params.conf

echo "Creating a file /etc/nginx/sites-available/landing.conf..."
cp config/landing.conf /etc/nginx/sites-available/
# Link 2 files and remove the default one
ln -s /etc/nginx/sites-available/landing.conf /etc/nginx/sites-enabled/landing.conf
rm -rf /etc/nginx/sites-enabled/default

# Restart nginx
echo "Reloading nginx..."
systemctl restart nginx
echo "nginx status"
systemctl status nginx

# Propose a vitrine website
echo "Loading website..."
cp -R landing /var/www/

echo "Reload Portsentry configuration"
service ufw restart
echo "Reload Fail2ban configuration"
fail2ban-client reload
echo "Fail2ban status"
service fail2ban status
echo "Reload Portsentry configuration"
service portsentry restart
echo "Portsentry status"
service portsentry status
echo "Reload nginx configuration"
service nginx restart

echo "Automatic configuration done"
echo "


Please complete the SSH configuration for the public key authentication by following those guidelines.
"
echo "-- run the command without the $ --
On host:
$ ssh-keygen
$ ssh-copy-id $new_user@192.168.56.2
or copy the key manually into ~/.ssh/Authorized_keys file
[that hostname is corresponding to our setup]"
ip a | grep enp0s8| grep inet
echo "When it's done, to enable ssh public key username, edit /etc/ssh/sshd_config file
$ sudo vim /etc/ssh/sshd_config
uncomment and change those lines
  #PubkeyAuthentication yes
  #AuthorizedKeysFile .ssh/authorized_keys
  #PermitRootLogin no
  #PasswordAuthentication no
then Restart service
$ sudo service ssh restart
You can now connect to remote-host via ssh by typing
$ $new_user@192.168.56.2 -p2223
"

echo "On Then reboot, stop undesired services (you can see which one are running typing)
$ service --status-all"
