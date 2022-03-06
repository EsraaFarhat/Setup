#!/usr/bin/bash

chmod 777 start.sh

# INSTALL CURL
sudo apt -y update

sudo apt install -y curl

# INSTALL git
sudo apt -y update

sudo apt install -y git

# INSTALL Node and npm
sudo apt-get -y update

sudo apt-get -y upgrade

wget https://nodejs.org/dist/v16.14.0/node-v16.14.0-linux-armv7l.tar.xz

tar -xf node-v16.14.0-linux-armv7l.tar.xz

cd node-v16.14.0-linux-armv7l/

sudo cp -R * /usr/local/

npm -v

cd ..

# INSTALL POSTGRES
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

sudo apt-get -y update

sudo apt-get install postgresql -y

# sudo apt-get install postgresql-12 -y

sudo sed -i 's/local   all             postgres                                peer/local   all             postgres                                md5/'  /etc/postgresql/13/main/pg_hba.conf
sudo sed -i 's/host    all             all             127.0.0.1\/32            md5/host    all             all            0.0.0.0\/0              md5/'  /etc/postgresql/13/main/pg_hba.conf

sudo systemctl restart postgresql

sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

sudo -u postgres psql -c "CREATE DATABASE loc_web_lite;"


## INSTALL INFLUXDB
sudo curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -

sudo echo "deb https://repos.influxdata.com/ubuntu bionic stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

sudo apt -y update

sudo apt install influxdb

sudo systemctl start influxdb

influx << EOF
CREATE USER admin WITH PASSWORD 'loclogsdb' WITH ALL PRIVILEGES
EOF

sudo sed -i 's/auth-enabled = false/auth-enabled = true/'  /etc/influxdb/influxdb.conf

sudo systemctl restart influxdb

influx -username 'admin' -password 'loclogsdb' << EOF
CREATE DATABASE loc_logs_lite   
EOF

# INSTALL THE Backend
git clone https://github.com/EsraaFarhat/LOC-web-lite.git

cd LOC-web-lite

sudo npm i

export PRIVATE_KEY=Z2Jj8rVO+c5WKx1eO6CdxlMzl05iHX9N3+z8KuVDlkHOrKmYh2qbQgjVA8rznOzCDu5vyB3zMzPbRvfQyymkvzwCsVpwczdUj9qjELRSo4Y0btu2Do/Jpm9FTiQWqDlxzmPx4lT6wiJAZldvzPrV+r0Vij95h7RNt56+jhUWbLiAyKcmMUZe5PVGqlVN8ic0XBmdo1W8U4CxQr5eoGhCyggyabCtfvrn62SHYZHhnADWdz1sog7hVLt53k5T7fW9W0I8tPpxlQKPF4H42EMLzGkndi4XMDSiVJKb0P0mtRYNofCa93fRj/Yo7XKtu8PaHG9jNgNjKRWAuT4TWRshkA==
export MY_IP=`hostname -I`
# export DATABASE_USERNAME=postgres
# export DATABASE_PASSWORD=postgres
# export DATABASE_HOST=localhost
# export DATABASE_DIALECT=postgres
# export DATABASE_NAME=loc_web_lite 
# export DATABASE_PORT=5432

# export INFLUXDB_NAME=loc_logs_lite
# export INFLUXDB_USERNAME=admin
# export INFLUXDB_PASSWORD=loclogsdb
# export INFLUXDB_HOST=localhost

# export MESSAGE=TryingToGenerateToken

# export EC2_URL=http://18.189.156.89:3000


node ./db/postgres/tables.js 

sudo npm install -g pm2

pm2 start index.js

cd ..

# INSTALL THE Frontend
 mkdir ~/www
 git clone https://github.com/aya-maher/LOC_WebLite_Build.git
 sudo apt install nginx
# sudo apt-get install ufw
 sudo cp /etc/nginx/sites-available/default ~
sudo sed -i 's/root \/var\/www\/html;/root \/home\/pi\/www;/'  /etc/nginx/sites-available/default
sudo systemctl reload nginx.service
cp -a /home/pi/LOC_WebLite_Build/. /home/pi/www