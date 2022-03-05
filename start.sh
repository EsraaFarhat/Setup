#!/usr/bin/bash

chmod 777 start.sh

# INSTALL POSTGRE
sudo sh -c 'echo "deb http://apt.postgresql.org/pub/repos/apt $(lsb_release -cs)-pgdg main" > /etc/apt/sources.list.d/pgdg.list'

wget --quiet -O - https://www.postgresql.org/media/keys/ACCC4CF8.asc | sudo apt-key add -

sudo apt-get update

sudo apt-get install postgresql

sudo apt-get install postgresql-12

sudo -u postgres psql -c "ALTER USER postgres PASSWORD 'postgres';"

sudo -u postgres psql -c "CREATE DATABASE loc_web_lite;"


# INSTALL INFLUXDB
sudo curl -sL https://repos.influxdata.com/influxdb.key | sudo apt-key add -

sudo echo "deb https://repos.influxdata.com/ubuntu bionic stable" | sudo tee /etc/apt/sources.list.d/influxdb.list

sudo apt update

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

# INSTALL THE PROJECT
git clone https://github.com/EsraaFarhat/LOC-web-lite.git

cd LOC-web-lite

sudo npm i

export PRIVATE_KEY=Z2Jj8rVO+c5WKx1eO6CdxlMzl05iHX9N3+z8KuVDlkHOrKmYh2qbQgjVA8rznOzCDu5vyB3zMzPbRvfQyymkvzwCsVpwczdUj9qjELRSo4Y0btu2Do/Jpm9FTiQWqDlxzmPx4lT6wiJAZldvzPrV+r0Vij95h7RNt56+jhUWbLiAyKcmMUZe5PVGqlVN8ic0XBmdo1W8U4CxQr5eoGhCyggyabCtfvrn62SHYZHhnADWdz1sog7hVLt53k5T7fW9W0I8tPpxlQKPF4H42EMLzGkndi4XMDSiVJKb0P0mtRYNofCa93fRj/Yo7XKtu8PaHG9jNgNjKRWAuT4TWRshkA==

node ./db/postgres/tables.js 

