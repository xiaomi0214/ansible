#/bin/bash
INSTALL_DIR=/data/mysql
DATADIR=/data/mysql/data
BOOST_VERSION='boost_1_59_0'
VERSION='mysql-5.7.23'
SOURCE_DIR=/tmp
install_mysql()
{
	PASSWD="123456"
	if [ ! -d  ${DATADIR} ]
	then
		mkdir -p ${DATADIR}/{data,run,logs}
	fi
	
	yum install gcc-c++ gcc make cmake ncurses-devel bison-devel -y
	cd ${SOURCE_DIR}
	tar xzvf $VERSION.tar.gz 
	tar xzvf $BOOST_VERSION.tar.gz 
	
	cd $VERSION
	cmake . -DCMAKE_INSTALL_PREFIX=$INSTALL_DIR \
        -DMYSQL_DATADIR=$DATADIR \
        -DMYSQL_UNIX_ADDR=$INSTALL_DIR/run/mysql.sock \
        -DDEFAULT_CHARSET=utf8 \
        -DDEFAULT_COLLATION=utf8_general_ci \
        -DWITH_INNOBASE_STORAGE_ENGINE=1 \
        -DWITH_MYISAM_STORAGE_ENGINE=1 \
        -DWITH_PARTITION_STORAGE_ENGINE=1 \
        -DWITH_BOOST=$SOURCE_DIR/$BOOST_VERSION \
        -DENABLED_LOCAL_INFILE=1 \
        -DEXTRA_CHARSETS=all
	
	make -j `grep processor /proc/cpuinfo | wc -l`
    make install
	
	if [ $? -ne 0 ]
	then 
		echo "mysql install failed"
		exit $?
	fi

	sleep 2
	
	id mysql &>/dev/null
	if [ $? -ne 0 ]
	then
		useradd mysql -s /sbin/nologin -M
	fi
	cp -p $INSTALL_DIR/support-files/mysql.server  /etc/init.d/mysqld
	touch $INSTALL_DIR/logs/mysqld.log
	chown -R mysql:mysql ${INSTALL_DIR}
	$INSTALL_DIR/bin/mysqld --initialize --basedir=$INSTALL_DIR --datadir=$DATADIR --user=mysql    
	/etc/init.d/mysqld start
    if [ $? -ne 0 ];then
        echo "mysql start is failed!"
        exit $?
    fi
    chkconfig --add mysqld
    chkconfig mysqld on
    root_pass=`grep 'temporary password' $INSTALL_DIR/logs/mysqld.log | awk '{print $11}'`
    $INSTALL_DIR/bin/mysql --connect-expired-password -uroot -p$root_pass -e "alter user 'root'@'localhost' identified by '$PASSWD';"    
	if [ $? -eq 0 ];then
            echo "+---------------------------+"
            echo "+------mysql安装完成--------+"
            echo "+---------------------------+"
    fi
    echo "export PATH=$PATH:$INSTALL_DIR/bin" >> /etc/profile
    source /etc/profile
}
install_mysql
