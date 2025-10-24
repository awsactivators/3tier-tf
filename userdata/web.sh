#!/bin/bash
set -euxo pipefail

# Run Node tasks as ec2-user (NVM needs user home)
su - ec2-user -c '
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
  . ~/.nvm/nvm.sh
  nvm install 16
  nvm use 16

  mkdir -p ~/web-tier
  aws s3 cp s3://mytumisbucket/web-tier/ ~/web-tier --recursive
  cd ~/web-tier
  npm install
  npm run build
'

amazon-linux-extras install nginx1 -y
cd /etc/nginx
rm -f nginx.conf
aws s3 cp s3://mytumisbucket/nginx.conf .
service nginx restart
chkconfig nginx on
chmod -R 755 /home/ec2-user