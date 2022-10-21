## Task 4.1 DATABASE ADMINISTRATION

### PART 1 DATABASE BASICS

![Database schema](screenshots/schema.png)


#### MySQL installation
[`Vagrantfile`](Vagrantfile)
```
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  config.vm.box = "ubuntu/focal64"

  config.vm.define "db-server" do |db|
      db.vm.network "private_network", ip: "192.168.12.8"
      db.vm.network "forwarded_port", guest: 3306, host: 3306
      db.vm.provision :shell, path: "bootstrap.sh"
  end
end
```

[`bootstrap.sh`](bootstrap.sh)
```
#!/usr/bin/env bash

# initialize variables
DBHOST=%
DBNAME=LAPD
DBUSER=user
DBPASSWD=tustan

#  prepare installation
apt-get update

debconf-set-selections <<< "mysql-server mysql-server/root_password password $DBPASSWD"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $DBPASSWD"

# install mysql
apt-get -y install mysql-server mysql-client

# create user and grant access
mysql -uroot -p$DBPASSWD -e "CREATE USER '$DBUSER'@'$DBHOST' IDENTIFIED BY '$DBPASSWD';GRANT ALL ON *.* TO '$DBUSER'@'$DBHOST';FLUSH PRIVILEGES;CREATE DATABASE $DBNAME;"

# update mysql conf file to allow remote access to the db
sudo sed -i "s/.*bind-address.*/bind-address = 0.0.0.0/" /etc/mysql/mysql.conf.d/mysqld.cnf

sudo service mysql restart
```


#### Database schema
```
    USE LAPD;
    CREATE TABLE violators (
        id INT PRIMARY KEY AUTO_INCREMENT,
        full_name VARCHAR(100) NOT NULL,
        address VARCHAR(100) NOT NULL
    );

    CREATE TABLE officers (
        badge_num INT PRIMARY KEY UNIQUE,
        full_name VARCHAR(100) NOT NULL
    );

    CREATE TABLE tickets (
        id INT PRIMARY KEY AUTO_INCREMENT,
        officers_badge INT NOT NULL,
        paid BOOLEAN NOT NULL,
        FOREIGN KEY (officers_badge) REFERENCES officers (badge_num)
    );

    CREATE TABLE violations (
        id INT PRIMARY KEY AUTO_INCREMENT,
        violation_date DATETIME,
        ticket_id INT NOT NULL,
        violator_id INT NOT NULL,
        FOREIGN KEY (ticket_id) REFERENCES tickets (id) ON DELETE CASCADE,
        FOREIGN KEY (violator_id) REFERENCES violators (id)
    );

    CREATE TABLE vehicles(
        id INT PRIMARY KEY AUTO_INCREMENT,
        plate_number VARCHAR(100) NOT NULL
    );
```

Correct schema with some DDL commands:
```
ALTER TABLE violators ADD phone VARCHAR(20) NOT NULL UNIQUE;
DROP TABLE vehicles;
```


#### Tables data
```
INSERT INTO officers (badge_num, full_name) VALUES
('1000', 'John Doe'),
('1001', 'John Walker'),
('1002', 'Margaret Thatcher'),
('2000', 'Kim Basinger'),
('1003', 'Harry Dillinger');

INSERT INTO violators (full_name, address, phone) VALUES
('Gerhard Schroeder', '32004 Germany, Berlin', '32222312'),
('Richard Stallman', '12000 USA, NY', '1024'),
('Steve Jobs', '12010 USA, CA Palo-Alto', '666'),
('Karla Bruni', '4302 Italy, Torino', '0021234568982312'),
('Bjarne Stroustrup', '54023 Denmark, Aarhus', '#0000002b');

INSERT INTO tickets (officers_badge, paid) VALUES
('1000', '1'),
('1001', '1'),
('2000', '0'),
('1001', '0'),
('1003', '0');

INSERT INTO violations (violation_date, ticket_id, violator_id) VALUES
('2021-12-20 18:00:02', '1', '3'),
('2021-12-20 18:01:02', '2', '3'),
('2021-12-20 18:02:02', '3', '3'),
('1984-04-02 02:05:15', '4', '5'),
('2001-11-04 16:16:16', '5', '1');
```

Make corrections:
```
UPDATE tickets SET paid = '0' WHERE id = 4;
```


#### SQL queries
```
USE LAPD;
SELECT V.id, V.violation_date AS 'Date', Vr.full_name AS Violator, O.full_name AS Punisher
FROM violations AS V
JOIN tickets AS T ON V.ticket_id = T.id
JOIN violators AS Vr ON V.violator_id = Vr.id
JOIN officers AS O ON O.badge_num = T.officers_badge;

SELECT * FROM officers WHERE badge_num = 2000;
SELECT * FROM violators ORDER BY phone DESC;
SELECT officers_badge, COUNT(*) AS is_paid FROM tickets WHERE paid = 1 GROUP BY officers_badge;

DELETE FROM tickets WHERE officers_badge = '2000';
```

#### User database
Create users:
```
CREATE USER 'police_officer'@'localhost' IDENTIFIED WITH mysql_native_password BY 'robocop';
CREATE USER 'police_chief'@'localhost' IDENTIFIED WITH mysql_native_password BY 'robochief';
```

Give permissions:
```
GRANT CREATE, DROP, DELETE, INSERT, SELECT, UPDATE on LAPD.tickets TO 'police_officer'@'localhost';
SHOW GRANTS FOR 'police_officer'@'localhost';
GRANT ALL PRIVILEGES on LAPD.* TO 'police_chief'@'localhost';
SHOW GRANTS FOR 'police_chief'@'localhost';
```

Correct the mistake:
```
REVOKE CREATE, DROP, DELETE on LAPD.tickets FROM 'police_officer'@'localhost';
SHOW GRANTS FOR 'police_officer'@'localhost';
FLUSH PRIVILEGES;
```

Test the permissions:
```
mysql -uroot -p -e "SELECT user,authentication_string,plugin,host FROM mysql.user WHERE user LIKE 'police_%';"
```
Police officer has the permission to select data from `tickets` table:
```
mysql -upolice_officer -p -e "SELECT * FROM LAPD.tickets;"
```
But doesn't have one for any other:
```
mysql -upolice_officer -p -e "SELECT * FROM LAPD.violations;"
```
Police department chief does have all the permissions for `LAPD` database:
```
mysql -upolice_chief -p -e "SELECT * FROM LAPD.violations;"
```
But can't even select data from other databases:
```
mysql -upolice_chief -p -e "SELECT * FROM mysql.user;"

```

![SQL queries](screenshots/SQL-queries.png)

#### Main DB tables
```
USE mysql;
SHOW databases;
SHOW tables;
SELECT * FROM db;
```

### PART 2 DATABASE TRANSFER

#### Database backup

```
mysqldump -uroot -p LAPD > /vagrant/LAPD_base.sql
```

Corrupt the database:
```
mysql -uroot -p -e "DROP table LAPD.violations;"
mysql -uroot -p -e "SHOW TABLES IN LAPD;"
```
Restore the database:
```
mysql -uroot -p LAPD < /vagrant/LAPD_base.sql
mysql -uroot -p -e "SHOW TABLES IN LAPD;"
```

Make a check:
```
mysql -upolice_chief -p -e "SELECT * FROM LAPD.violations ORDER BY violation_date DESC;"
```


#### AWS RDS
Move local database to a newly created RDS MySQL (`dbplayground`):
```
mysql -uuser -p -h dbplayground.c25irogbj3nw.eu-central-1.rds.amazonaws.com LAPD < /vagrant/LAPD_base.sql
```

Connect to `dbplayground`:
```
mysql -uuser -p -h dbplayground.c25irogbj3nw.eu-central-1.rds.amazonaws.com
```
![AWS RDS LAPD DB](screenshots/AWSRDS.png)

Make a dump:
```
mysqldump -uuser -p -h dbplayground.c25irogbj3nw.eu-central-1.rds.amazonaws.com LAPD > /vagrant/dbplayground-LAPD.sql
```

### PART 3 DYNAMODB
![Amazon DynamoDB](screenshots/SteveJobs.png)

