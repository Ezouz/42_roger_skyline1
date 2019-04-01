#!/bin/bash
date >> /var/log/update_script.log
apt-get update -y >> /var/log/update_script.log
apt-get upgrade -y >> /var/log/update_script.log