#!/bin/bash

install=false
cleanwww=false
xbt=false
gitu232="https://github.com/Bigjoos/U-232-V5.git"

WWW_DIR="/var/www/html"
DOCUMENT_ROOT="$WWW_DIR/u232v5"

while getopts ":i:x:c:g:" opt; do
    case "$opt" in
        i)
            if [ $OPTARG == "true" ]; then
               install=true
            fi ;;
        x)
            if [ $OPTARG == "false" ]; then
               xbt=false
            fi ;;
        c)
            if [ $OPTARG == "true" ]; then
               cleanwww=true
            fi ;;
        g)
            if [ $OPTARG ]; then
               gitu232=$OPTARG
            fi ;;
    esac
done

echo "****************************************"
echo "Clean /var/www before clone: $cleanwww"
echo "U232 install menu:           $install"
echo "XBT compiled and installed:  $xbt"
echo "****************************************"


cat > /etc/apt/sources.list.d/php7.list <<EOF
deb http://packages.dotdeb.org jessie all
deb-src http://packages.dotdeb.org jessie all
EOF

echo "Adding apt repositories for ..."
echo "- PHP 7.0 repo: dotdeb.org"
wget --quiet -O - https://www.dotdeb.org/dotdeb.gpg | apt-key add -
rm -f dotdeb.gpg
echo "- Mailhog repo: deogracia.xyz"
echo "deb http://repo.deogracia.xyz/debian precise contrib" >> /etc/apt/sources.list.d/mailhog-debian-package.list
wget --quiet -O - http://l.deogracia.xyz/2 | apt-key add -

export DEBIAN_FRONTEND=noninteractive

apt-get clean
echo "Updating apt ..."
apt-get update -qq
echo "Installing apache, php, git, memcached ... (this will take a while)"
apt-get -qq -force=yes install git apache2 php7.0 php7.0-common php7.0-fpm sysvinit-utils memcached > /dev/null
apt-get -qq -force=yes install php7.0-mysql php7.0-gd php7.0-json php7.0-cli php7.0-curl php7.0-memcached libapache2-mod-php7.0 php7.0-mbstring > /dev/null
#debconf-set-selections <<< 'mysql-server mysql-server/root_password password admin'
#debconf-set-selections <<< 'mysql-server mysql-server/root_password_again password admin'

echo "Installing MySQL server, client..."
apt-get -qq -force=yes install mysql-server mysql-client >/dev/null && echo "Done" || echo "Failed"
apt-cache policy mysql-server 2>&1 | grep "Installed:"

#
# MySQL config
#

# create database u232;
# grant all privileges on u232.* to u232@localhost identified by 'u232';
MYSQL_NAME="u232"
MYSQL_USER="u232"
MYSQL_PASS="u232"
MYSQL_ROOTPWD=`openssl rand -base64 12`
MYSQL_TMPFILE=`mktemp --suffix=.sql`

#echo "UPDATE mysql.user SET Password=PASSWORD('$MYSQL_ROOTPWD') WHERE User='root';" | tee -a $MYSQL_TMPFILE
#echo "DELETE FROM mysql.user WHERE User='root' AND Host NOT IN ('localhost', '127.0.0.1', '::1');" | tee -a $MYSQL_TMPFILE
#echo "DELETE FROM mysql.user WHERE User='';" | tee -a $MYSQL_TMPFILE
#echo "DROP DATABASE test;" | tee -a $MYSQL_TMPFILE

echo "DELETE FROM mysql.db WHERE Db='test' OR Db='test\\_%';" > $MYSQL_TMPFILE
echo "CREATE DATABASE $MYSQL_NAME CHARACTER SET 'utf8';" >> $MYSQL_TMPFILE
echo "GRANT ALL PRIVILEGES ON $MYSQL_NAME.* TO '$MYSQL_USER'@'127.0.0.1' IDENTIFIED BY '$MYSQL_PASS';" >> $MYSQL_TMPFILE
echo "GRANT ALL PRIVILEGES ON $MYSQL_NAME.* TO '$MYSQL_USER'@'localhost' IDENTIFIED BY '$MYSQL_PASS';" >> $MYSQL_TMPFILE
echo "GRANT ALL PRIVILEGES ON $MYSQL_NAME.* TO '$MYSQL_USER'@'%' IDENTIFIED BY '$MYSQL_PASS';" >> $MYSQL_TMPFILE
echo "FLUSH PRIVILEGES;" >> $MYSQL_TMPFILE

echo
echo "Creating $MYSQL_NAME DDBB witih $MYSQL_USER/$MYSQL_PASS:"
cat $MYSQL_TMPFILE | mysql -u root && echo "Done" || echo "Failed"
rm $MYSQL_TMPFILE

sed -i 's/^bind-address.*/bind-address        = 0.0.0.0/' /etc/mysql/my.cnf
sed -i 's/^skip-external-locking.*/#skip-external-locking/' /etc/mysql/my.cnf
service mysql restart


GIT_REPO=$gitu232

if [ -d $DOCUMENT_ROOT ] && [ $cleanwww == "true" ]; then
    echo "Removing $DOCUMENT_ROOT"
    rm -rf $DOCUMENT_ROOT
fi

if [ ! -d $DOCUMENT_ROOT ] || [ ! -f $DOCUMENT_ROOT/index.php ]; then

    cd $WWW_DIR
    echo "Cloning $GIT_REPO to $DOCUMENT_ROOT ..."
    git clone -q $GIT_REPO $DOCUMENT_ROOT

    cd $DOCUMENT_ROOT

    if [ $install == "false" ]; then
        echo "Installing a pr generated configuration (config.php, ann_config.php)"
        cp /vagrant/include/ann_config.php include
        cp /vagrant/include/config.php include

        sed -i "s/^\$INSTALLER09\['mysql_user'\].*/\$INSTALLER09['mysql_user'] = '${MYSQL_USER}';/" include/config.php
        sed -i "s/^\$INSTALLER09\['mysql_user'\].*/\$INSTALLER09['mysql_user'] = '${MYSQL_USER}';/" include/ann_config.php
        sed -i "s/^\$INSTALLER09\['mysql_pass'\].*/\$INSTALLER09['mysql_pass'] = '${MYSQL_PASS}';/" include/config.php
        sed -i "s/^\$INSTALLER09\['mysql_pass'\].*/\$INSTALLER09['mysql_pass'] = '${MYSQL_PASS}';/" include/ann_config.php
        sed -i "s/^\$INSTALLER09\['mysql_db'\].*/\$INSTALLER09['mysql_db'] = '${MYSQL_NAME}';/" include/config.php
        sed -i "s/^\$INSTALLER09\['mysql_db'\].*/\$INSTALLER09['mysql_db'] = '${MYSQL_NAME}';/" include/ann_config.php
    fi

    if [ ! -f .gitignore ]; then
        echo "include/ann_config.php" > .gitignore
        echo "include/config.php" >> .gitignore
        echo "include/backup/*" >> .gitignore
        echo "cache/staff_setttings.php" >> .gitignore
        echo "cache/staff_setttings2.php" >> .gitignore
        echo "install/*" >> .gitignore
        echo "imddb/cache/*" >> .gitignore
        echo "rss.xml" >> .gitignore
        echo "rssdd.xml" >> .gitignore
        echo "torrents/*" >> .gitignore
        echo ".gitignore" >> .gitignore
        echo "pic/*" >> .gitignore
        echo "Log_Viewer/*" >> .gitignore
        echo "GeoIP/*" >> .gitignore
        echo "pic.tar.gz" >> .gitignore
        echo "Log_Viewer.tar.gz" >> .gitignore
        echo "GeoIP.tar.gz" >> .gitignore
    fi

    find ./install -type f -exec git update-index --assume-unchanged '{}' \; 
    if [ $install == "false" ]; then
        rm -rf install
        sed -i "s/\$INSTALLER09\['captcha_on'\] = true;/\$INSTALLER09\['captcha_on'\] = false;/" cache/site_settings.php
        sed -i "s/\$INSTALLER09\['dupeip_check_on'\] = true;/\$INSTALLER09\['dupeip_check_on'\] = false;/" cache/site_settings.php
        sed -i "s/\$INSTALLER09\['allowed_staff'\].*/\$INSTALLER09\['allowed_staff'\]\['id'\] = array(1,2);/" cache/staff_settings.php
        sed -i "s/\$INSTALLER09\['staff'\].*/\$INSTALLER09\['staff'\]\['allowed'\] = array('admin' => 1, 'system' => 2);/" cache/staff_settings2.php
    fi

    git update-index --assume-unchanged cache/site_settings.php
    git update-index --assume-unchanged cache/staff_settings.php
    git update-index --assume-unchanged cache/staff_settings2.php

    cd $DOCUMENT_ROOT

    echo "Extracting tar.gz:"

    for file in *.tar.gz; do
        echo "- Extracting: $file"
        tar xzf $file && rm -f $file || echo "Failed extract $file"
    done

    if [ -f /var/www/html/index.html ]; then
       rm -f /var/www/html/index.html
    fi

    code_not_updated=false
else
    echo "The directory $DOCUMENT_ROOT already exist. Code not updated."
    code_not_updated=true
fi

#
# FPM configugración y cambio sock file por puerto TCP
#

# http://www.geoffstratton.com/2014/05/ubuntu-14-apache-php/
# ;listen = /var/run/php7-fpm.sock

sed -i 's/^listen .*/listen = 127.0.0.1:9000/' /etc/php/7.0/fpm/pool.d/www.conf && echo "Configured php-fpm port"

a2enmod proxy_fcgi >/dev/null

ADMINER_DIR=/opt/adminer
if [ ! -d $ADMINER_DIR ]; then
    echo "Installing adminer (like php admin but smaller)"
    mkdir $ADMINER_DIR
    wget --quiet "http://www.adminer.org/latest.php" -O $ADMINER_DIR/adminer.php
    chown www-data: $ADMINER_DIR -R
fi

cat > /etc/apache2/sites-available/u232.conf << EOF
<VirtualHost *:80>
        ServerAdmin webmaster@localhost
        DocumentRoot $DOCUMENT_ROOT
        ErrorLog \${APACHE_LOG_DIR}/u232-error.log
        CustomLog \${APACHE_LOG_DIR}/u232-access.log combined
        # Possible values include: debug, info, notice, warn, error, crit,
        # alert, emerg.
        LogLevel warn
        <Directory $ADMINER_DIR>
            Require all granted
        </Directory>
        Alias /adminer $ADMINER_DIR/adminer.php
        ProxyPassMatch ^/(.*\.php(/.*)?)$ fcgi://127.0.0.1:9000${DOCUMENT_ROOT}/\$1
</VirtualHost>
EOF

#
# Disable default sites and enable our site
#

a2dissite 000-default >/dev/null
a2ensite u232 >/dev/null
a2enmod rewrite >/dev/null
a2enmod proxy_fcgi >/dev/null
service php7.0-fpm restart
service apache2 restart


echo "Changing file owner to www-data on $DOCUMENT_ROOT"
chown -R www-data: $DOCUMENT_ROOT && echo "Done" || echo "Failed"

#
# MySQL base de datos inicial 
#

if [ $install == "false" ]; then
    echo "Generating a initial database with users 'admin/admin1234' and 'system/system1234'"
    mysql u232 < /vagrant/db-dev.sql && echo "Done" || echo "Failed"
fi


#
# Tracker XBT (optional)
#

if [ $xbt == "true" ]; then

    XBT_DEV_DIR=/opt
    XBT_DIR=$XBT_DEV_DIR/xbt/Tracker
    XBT_BIN=$XBT_DIR/xbt_tracker

    cd $XBT_DEV_DIR
    echo "Installing packages needed to compile XBT"
    apt-get -qq install cmake g++ libboost-dev libmysqlclient-dev make zlib1g-dev > /dev/null
    wget --quiet https://github.com/whocares-openscene/u-232-xbt/raw/master/xbt.tar.gz || echo "Error downloading xbt.tar.gz!!!"
    tar xzf xbt.tar.gz xbt/misc xbt/Tracker && echo "Extracted xbt.tar.gz" || echo "Extract xbt.tar.gz FAILED!!!"
    cd $XBT_DIR
    cp -f $DOCUMENT_ROOT/XBT/* .
    echo "Compiling XBT .."
    ./make.sh > /dev/null && echo "Done" || echo "Failed"

    #
    # XBT configuration file
    #
    echo "Configuring xbt_tracker.conf ..."

    sed -i "s/^mysql_host=.*/mysql_host=localhost/" xbt_tracker.conf
    sed -i "s/^mysql_user=.*/mysql_user=${MYSQL_USER}/" xbt_tracker.conf
    sed -i "s/^mysql_password=.*/mysql_password=${MYSQL_PASS}/" xbt_tracker.conf
    sed -i "s/^mysql_database=.*/mysql_database=${MYSQL_NAME}/" xbt_tracker.conf


    if [ -f $XBT_BIN ]; then
      echo "XBT binary available on $XBT_BIN. Activating it on system startup ..."
      sed -i "s#^exit 0#cd $XBT_DIR && $XBT_BIN#" /etc/rc.local && echo "Done" || echo "Failed"
    fi
fi

#
# Mailhog to capture all outgoing email
#
# Listens port 8025: Web interface
# Listens port 1025: Mailhog smtp
#

echo "Uninstalling exim4.. "
apt-get -qq remove --purge exim4 > /dev/null
echo "Installing mailhog..."
apt-get -qq install -force=yes mailhog > /dev/null && echo "Done" || echo "Install mailhog FAILED!!!"

# Make PHP sendmail_path points through mhsendmail to forward on mailhog

wget --quiet https://github.com/mailhog/mhsendmail/releases/download/v0.2.0/mhsendmail_linux_amd64 -O /usr/local/bin/mhsendmail || echo "Download mhsendmail FAILED!!!"
chmod 755 /usr/local/bin/mhsendmail
sed -i 's#^;sendmail_path.*#sendmail_path = "/usr/local/bin/mhsendmail"#' /etc/php/7.0/fpm/php.ini
service php7.0-fpm restart

echo
echo
echo "****************************************"
echo "Clean /var/www before clone: $cleanwww"
echo "U232 install menu:           $install"
echo "XBT compiled and installed:  $xbt"
echo "****************************************"
if [ $code_not_updated == "true" ]; then
  echo "XBT PHP code not updated from git"
  echo "****************************************"
fi
echo
echo
echo "MySQL root pass: (is empty)"
# echo "MySQL root pass: $MYSQL_ROOTPWD"
echo "MySQL U232 DBname:   $MYSQL_NAME"
echo "MySQL U322 user:     $MYSQL_USER"
echo "MySQL U322 password: $MYSQL_PASS"
echo

if [ -f $XBT_BIN ]; then
  echo "XBT binary available on $XBT_BIN"
  echo
fi


echo "****************************************"
echo "Access U232 on http://localhost:8080 (outside VM)"
echo "Access Adminer on http://localhost:8080/adminer (outside VM)"
echo "Access Mailhog on http://localhost:8025 (outside VM)"
echo "****************************************"
