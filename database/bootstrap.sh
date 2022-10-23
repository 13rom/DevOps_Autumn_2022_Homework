#!/usr/bin/env bash

case $HOSTNAME in
mysql-vm)
    # initialize variables
    DBHOST=%
    DBNAME=LAPD
    DBUSER=user
    DBPASSWD=tustan

    #  prepare installation
    apt-get update

    debconf-set-selections <<<"mysql-server mysql-server/root_password password $DBPASSWD"
    debconf-set-selections <<<"mysql-server mysql-server/root_password_again password $DBPASSWD"

    # install mysql
    apt-get -y install mysql-server mysql-client

    # create user and grant access
    mysql -uroot -p$DBPASSWD -e "CREATE USER '$DBUSER'@'$DBHOST' IDENTIFIED BY '$DBPASSWD';GRANT ALL ON *.* TO '$DBUSER'@'$DBHOST';FLUSH PRIVILEGES;CREATE DATABASE $DBNAME;"

    # update mysql conf file to allow remote access to the db
    sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

    service mysql restart
    ;;
mongo-vm)
    # prepare installation
    wget -qO - https://www.mongodb.org/static/pgp/server-6.0.asc | sudo apt-key add -
    echo "deb [ arch=amd64,arm64 ] https://repo.mongodb.org/apt/ubuntu focal/mongodb-org/6.0 multiverse" | sudo tee /etc/apt/sources.list.d/mongodb-org-6.0.list

    apt-get update

    # install mongodb
    apt-get install -y mongodb-org net-tools

    # fix ubuntu 20.04 permissions problem
    chown -R mongodb:mongodb /var/lib/mongodb
    chown mongodb:mongodb /tmp/mongodb-27017.sock

    # start mongod
    service mongod restart

    sleep 20

    mongosh < /vagrant/mongo_base.js
    ;;

esac
