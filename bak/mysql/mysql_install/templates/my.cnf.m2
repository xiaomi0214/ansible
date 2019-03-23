[mysqld]
character-set-server=utf8
collation-server=utf8_general_ci
explicit_defaults_for_timestamp=true
datadir=/data/mysql/data
socket=/data/mysql/run/mysql.sock
# Disabling symbolic-links is recommended to prevent assorted security risks
symbolic-links=0
# Settings user and group are ignored when systemd is used.
# If you need to run mysqld under a different user or group,
# customize your systemd unit file for mariadb according to the
# instructions in http://fedoraproject.org/wiki/Systemd

log-error=/data/mysql/logs/mysqld.log
pid-file=/data/mysql/run/mysqld.pid
[mysqld_safe]

#
# include all files from the config directory
#
!includedir /etc/my.cnf.d

