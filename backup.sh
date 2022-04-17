#!/bin/bash

isDel=n
args=$#
isDel=${!args}

test -f /etc/profile && . /etc/profile >/dev/null 2>&1
baseDir=$(cd $(dirname $0) && pwd)
# 使用zip作为压缩
tar --version >/dev/null || (echo "未安装tar.gz请先安装" && exit 2)
TAR=$(which tar)
# 定义python版本
PYTHON=$(which python3)
MYSQLDUMP=$(which mysqldump)

# 上传文件函数
uploadToCOS()
{
	# 下面参数后面的3为COS文件过期时间，可自定义
    $PYTHON $baseDir/backup.py $1 $2 3
    if [[ $? -eq 0 ]] &&  [[ "$isDel" == "y" ]]
    then
        test -f $2 && rm -f $2
    fi
}

printHelp()
{
clear
printf '
=====================================帮助说明=========================================
1. 数据库备份:
    1  [database]数据库备份
    2: [dbname] 数据库名称
    3: [mysqluser] 数据库用户名
    4: [mysqlpassword] 数据库密码
    5: [back_path] 临时目录（绝对路径）
    6: [isDel] 备份完成后是否删除本地文件删除后面加 y 

示 例:./backup.sh database dbname user 123456 /temp/

2. 备份网站或者文件:
    1  [file]文件或网站备份
    2: [domain] 名称
    3: [site_path] 文件路径
    4: [back_path] 备份路径
    5: [isDel] 删除文件 默认不删除，若删除最后加y参数

示 例:./backup.sh file test.cn /www/wwwroot/test.cn /temp/test.cn


'
exit 0
}

backupDB()
{
    dbname=$1
    mysqluser=$2
    mysqlpd=$3
    back_path=$4
    test -d $back_path || (mkdir -p $back_path || echo "$back_path 不存在，请检查文件" && exit 2)
    cd $back_path
    #如果是要备份远程MySQL，则修改如下语句中localhost为远程MySQL地址
    $MYSQLDUMP -hlocalhost -u$mysqluser -p$mysqlpd $dbname >$back_path/database_$dbname\_$(date +%Y%m%d)\.sql
    test -f $back_path/database_$dbname\_$(date +%Y%m%d)\.sql || (echo "数据库导出失败，请检查路径" && exit 2)
    $TAR  zcf $back_path/database_$dbname\_$(date +%Y%m%d)\.tar.gz $back_path/database_$dbname\_$(date +%Y%m%d)\.sql && \
    uploadToCOS database $back_path/database_$dbname\_$(date +%Y%m%d)\.tar.gz 
}

backupFile()
{
    domain=$1
    site_path=$2
    back_path=$3
    test -d $site_path || (echo "$file_path 不存在，请检查文件" && exit 2)
    test -d $back_path || (mkdir -p $back_path || echo "$back_path 不存在，请检查文件" && exit 2)
    test -f $back_path/$domain\_$(date +%Y%m%d)\.tar.gz && rm -f $back_path/$domain\_$(date +%Y%m%d)\.tar.gz
    $TAR -zcvf $back_path/$domain\_$(date +%Y%m%d)\.tar.gz $site_path && \
    uploadToCOS site $back_path/$domain\_$(date +%Y%m%d)\.tar.gz  
}

while [ $1 ]; do
    case $1 in
        '--database' | 'database' )
        backupDB $2 $3 $4 $5 $6
        exit
        ;;
        '--file' | 'file' )
        backupFile $2 $3 $4
        exit  
        ;;
        * )
        printHelp
        exit
        ;;
    esac
done
printHelp
