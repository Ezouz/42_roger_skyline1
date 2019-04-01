#!/bin/bash
echo "\033[33mConfiguration of the WEB SERVER NGINX\033[0m"
echo "\033[33mDO IT AS SUDOER\033[0m"

# UFW allow nginx
echo "\033[33mAllow Nginx connections\033[0m"
sudo ufw allow 'Nginx Full'

# create ssl certificates
echo "\033[33mCreating auto-signed ssl... Please fill the following form\033[0m"
sudo openssl req -x509 -nodes -days 365 -newkey rsa:2048 -keyout /etc/ssl/private/nginx-selfsigned.key -out /etc/ssl/certs/nginx-selfsigned.crt
echo "\033[33mCreating dh group...\033[0m"
sudo openssl dhparam -out /etc/nginx/dhparam.pem 512

# create snippets
echo "\033[33mCreating a file /etc/nginx/snippets/self-signed.conf...\033[0m"
sudo touch /etc/nginx/snippets/self-signed.conf
sudo sh -c "echo 'ssl_certificate /etc/ssl/certs/nginx-selfsigned.crt;\nssl_certificate_key /etc/ssl/private/nginx-selfsigned.key;' > /etc/nginx/snippets/self-signed.conf"

# cypher for ssl security
echo "\033[33mCreating a file ssl-params.conf in /etc/nginx/snippets/...\033[0m"
sudo cp config/ssl-params.conf /etc/nginx/snippets/
sudo chmod 644 /etc/nginx/snippets/ssl-params.conf

echo "\033[33mCreating a file /etc/nginx/sites-available/landing.conf...\033[0m"
sudo cp config/landing.conf /etc/nginx/sites-available/
# Link 2 files and remove the default one
sudo ln -s /etc/nginx/sites-available/landing.conf /etc/nginx/sites-enabled/landing.conf
sudo rm -rf /etc/nginx/sites-enabled/default

# Restart nginx
echo "\033[33mReloading nginx...\033[0m"
sudo systemctl restart nginx
echo "\033[33mnginx status\033[0m"
sudo systemctl status nginx

# Propose a vitrine website
echo "\033[33mLoading website...\033[0m"
sudo cp -R landing /var/www/