#!/bin/bash
set -euxo pipefail

yum -y update || true
yum -y install mariadb105 || yum -y install mariadb || true

su - ec2-user -c '
  curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.38.0/install.sh | bash
  . ~/.nvm/nvm.sh
  nvm install 16
  nvm use 16
  npm install -g pm2

  mkdir -p ~/app-tier
  aws s3 cp s3://mytumisbucket/app-tier/ ~/app-tier --recursive
  cd ~/app-tier
  npm install
  pm2 start index.js
  pm2 list
  pm2 logs --lines 10
  pm2 startup | sed "s/sudo //g" | bash
'