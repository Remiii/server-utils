#!/bin/bash

#############################
# Script webServerBackup.sh #
# Remiii - the 2013/04/18   #
#                           #
# Requirement: mysqldump    #
#############################

# Var
MY_DAY=`date +%Y-%m-%d_%H-%M`
MY_OLD_DAY=`date --date '15 days ago' +%Y-%m-%d_%H-%M`
DB_HOST='~'
DB_LOGIN='~'
DB_PWD='~'
FTP_HOST='~'
FTP_LOGIN='~'
FTP_PWD='~'
PWD_BACKUP='~'
NAME_DB_1='~'
NAME_DB_2='~'

function BACKUP_BDD()
{
    # Dump DB 1
    mysqldump --host=${DB_HOST} --user=${DB_LOGIN} --password=${DB_PWD} msc_website_prod3 > /${PWD_BACKUP}/${MY_DAY}_${NAME_DB_1}.sql
    rm /${PWD_BACKUP}/${MY_OLD_DAY}_${NAME_DB_1}.sql
    # Dump DB 2
    mysqldump --host=${DB_HOST} --user=${DB_LOGIN} --password=${DB_PWD} ${NAME_DB_2} > /${PWD_BACKUP}/${MY_DAY}_${NAME_DB_2}.sql
    rm /${PWD_BACKUP}/${MY_OLD_DAY}_${NAME_DB_2}.sql
    # Dump Apache conf
    tar -czf /${PWD_BACKUP}/${MY_DAY}_etc_apache2.tar.gz /etc/apache2/*
    rm /${PWD_BACKUP}/${MY_OLD_DAY}_etc_apache2.tar.gz
    # Dump PHP conf
    tar -czf /${PWD_BACKUP}/${MY_DAY}_etc_php.tar.gz /etc/php5
    rm /${PWD_BACKUP}/${MY_OLD_DAY}_etc_php.tar.gz
    # Dump Cron list
    crontab -l > /${PWD_BACKUP}/${MY_DAY}_cron.txt
    rm /${PWD_BACKUP}/${MY_OLD_DAY}_cron.txt
}

function BACKUP_FTP()
{
    ftp -in <<EOF
    open ${FTP_HOST}
    user ${FTP_LOGIN} ${FTP_PWD}
    bin
    verbose
    prompt
    lcd /${PWD_BACKUP}
    put ${MY_DAY}_${NAME_DB_1}.sql
    delete ${MY_OLD_DAY}_${NAME_DB_1}.sql
    put ${MY_DAY}_${NAME_DB_2}.sql
    delete ${MY_OLD_DAY}_${NAME_DB_2}.sql
    put ${MY_DAY}_etc_apache2.tar.gz
    delete ${MY_OLD_DAY}_etc_apache2.tar.gz
    put ${MY_DAY}_etc_php.tar.gz
    delete ${MY_OLD_DAY}_etc_php.tar.gz
    put ${MY_DAY}_cron.txt
    delete ${MY_OLD_DAY}_cron.txt
    bye
EOF
}

BACKUP_BDD

BACKUP_FTP
