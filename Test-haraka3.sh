#!/bin/bash

#give  your server ip address and your domain:
apt-get install vim -y
sed -i -e 's/127.0.0.1 localhost/67.205.149.163 duffar.xyz/g' /etc/hosts

#Nodejs Installation:
apt-get update
apt-get install curl -y
curl -o- https://raw.githubusercontent.com/nvm-sh/nvm/v0.37.2/install.sh | bash
. ~/.nvm/nvm.sh
nvm install --lts

#Pm2 Installation:
npm i -g pm2@5.1.2

#Haraka Installation:
apt-get update
apt-get install -y build-essential
npm config set user 0 && npm config set unsafe-perm true
sudo chown -R $(whoami) /root/.nvm/versions/node/
apt-get install python2.7 -y
ln -s /usr/bin/python2.7 /usr/bin/python
npm i -g Haraka@2.8.27
apt-get install git

#Nginx Installation:
apt-get update && apt-get install nginx -y

#Let’s Encrypt Installation:
sudo apt install software-properties-common
sudo apt install certbot python3-certbot-nginx -y

#Redis Installation:
apt-get update && apt-get install redis-server -y
sed -i 's/# requirepass foobared/requirepass es-nuke@2k21/g' /etc/redis/redis.conf
sed -i 's/bind 127.0.0.1 ::1/ bind 0.0.0.0 ::1/g' /etc/redis/redis.conf
systemctl restart redis-server
systemctl enable redis-server

#Swaks Installation:
apt-get update && apt-get install swaks -y

#Mongo Installation:
sudo apt-get install gnupg -y

wget -qO - https://www.mongodb.org/static/pgp/server-4.4.asc | sudo apt-key add -

echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu bionic/mongodb-org/4.4 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-4.4.list

sudo apt-get update

sudo apt-get install -y mongodb-org

mongo --version

echo "mongodb-org hold" | sudo dpkg --set-selections

echo "mongodb-org-server hold" | sudo dpkg --set-selections

echo "mongodb-org-shell hold" | sudo dpkg --set-selections

echo "mongodb-org-mongos hold" | sudo dpkg --set-selections

echo "mongodb-org-tools hold" | sudo dpkg --set-selections

sudo systemctl start mongod
sudo systemctl enable mongod

#Create Haraka Project and Configure:
#Step1: Clone Haraka Code from GitHub to server
cd /var/
git clone -b dev https://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@github.com/fissioninfotech/mail-server.git
cd /var/mail-server/config
touch auth_flat_file.ini
echo "me@duffar.xyz=duffar@123" >> /var/mail-server/config/auth_flat_file.ini
#Install the following commands in haraka Project:
cd /var/mail-server
npm i
npm i -g ip
npm i -g time-zone
npm i -g moment-timezone
npm i -g socket.io-client@2.3.0
npm i -g socket.io-server
npm i -g cors
npm install -g express
npm install haraka-plugin-mongodb
npm install mongodb

#Step 3: Add all our domains in the following file:
cd /var/mail-server/config
echo "duffar.xyz" >> host_list

#Step 4: Add one domain which we used for hostname in the following file:
cd /var/mail-server/config/
echo "duffar.xyz" >> me

#Step5 : create nginx reverse proxy for ip by using following code and create ssl for that domain:
cd /etc/nginx/sites-available
rm default
rm ../sites-enabled/default
touch link.domain.com
echo "server {
 #   listen 80;
 server_name  link.domain.com;
 
	location / {
        proxy_set_header X-Real-IP $remote_addr;
        proxy_set_header X-Forwarded-For $proxy_add_x_forwarded_for;
        proxy_set_header X-Forwarded-Proto $scheme;
        proxy_set_header Host $http_host;
        proxy_set_header X-NginX-Proxy true;
 
        proxy_pass https://IP:9091;
        proxy_redirect off;
 
    	# Socket.IO Support
        proxy_http_version 1.1;
        proxy_set_header Upgrade $http_upgrade;
        proxy_set_header Connection "upgrade";
	}
 
}" >> link.domain.com

#Do shortlink:
ln -s /etc/nginx/sites-available/link.domain.com /etc/nginx/sites-enabled/

#ADD SSL Certificates to HARAKA:
sudo certbot --nginx -d link.domain.com --redirect

# copy new key and replace old key:
cp -r /etc/letsencrypt/archive/link.domain.com/cert1.pem /var/mail-server/config/cert1.pem
cp -r /etc/letsencrypt/archive/link.domain.com/privkey1.pem /var/mail-server/config/privkey1.pem

#Records Binding: Create DKIM, DMARC, SPF records for your domains:
cd /var/mail-server/config/dkim
chmod +x dkim_key_gen.sh
./dkim_key_gen.sh domain.com

#Final step: Start haraka server using following commands:
cd /var/mail-server/
pm2 start “haraka -c .” --name Mail-server
pm2 save
pm2 startup

exit 








