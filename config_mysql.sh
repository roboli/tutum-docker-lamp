#!/bin/bash

/usr/bin/mysqld_safe > /dev/null 2>&1 &

RET=1
while [[ RET -ne 0 ]]; do
    echo "=> Waiting for confirmation of MySQL service startup"
    sleep 5
    mysql -uroot -e "status" > /dev/null 2>&1
    RET=$?
done

PASS=${MYSQL_PASS:-$(pwgen -s 12 1)}
_word=$( [ ${MYSQL_PASS} ] && echo "preset" || echo "random" )
echo "=> Creating MySQL admin user with ${_word} password"

mysql -uroot -e "CREATE USER 'admin'@'%' IDENTIFIED BY '$PASS'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'admin'@'%' WITH GRANT OPTION"

CHOFO_PASS=${MYSQL_CHOFO_PASS:-cal04023}
echo "=> Creating MySQL chofo user..."

mysql -uroot -e "CREATE USER 'chofo'@'%' IDENTIFIED BY '$CHOFO_PASS'"
mysql -uroot -e "GRANT ALL PRIVILEGES ON *.* TO 'chofo'@'%' WITH GRANT OPTION"

ROOT_PASS=${MYSQL_ROOT_PASS:-momo}
echo "=> Creating MySQL root password..."

mysql -u root -e "UPDATE mysql.user SET Password = PASSWORD('$ROOT_PASS') WHERE User = 'root'"

echo "=> Creating Aru database..."

mysql -u root -e "CREATE DATABASE lms"

echo "=> Installing Aru schema..."

mysql -u root -h localhost lms < /var/www/html/aru/Bases\ de\ Datos/lms.sql
mysql -u root -h localhost lms < /var/www/html/aru/Bases\ de\ Datos/lms_more.sql

echo "=> Done!"

echo "========================================================================"
echo "You can now connect to this MySQL Server using:"
echo ""
echo "    mysql -uadmin -p$PASS -h<host> -P<port>"
echo ""
echo "Please remember to change the above password as soon as possible!"
echo ""
echo "The password for 'root' is $ROOT_PASS  , only for local connections"
echo ""
echo "The password for 'chofo' is $CHOFO_PASS"
echo ""
echo "Database 'lms' was created"
echo ""
echo "The schema for 'lms' database was created"
echo "========================================================================"

mysqladmin -uroot shutdown
