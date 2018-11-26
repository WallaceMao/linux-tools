#!/bin/bash

usage(){ echo "Usage: $0 [-s <number>] [-k <number>]" 1>&2; exit 1; }

# default params
is_kill=0
sec=60

# parse option and params
while getopts ":s:k:" o; do
  case "${o}" in
    s)
      sec=${OPTARG}
      ;;
    k)
      is_kill=1
      sec=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done

echo "`date '+%Y-%m-%d %H:%M:%S'` second limit is ${sec}"

# loop params
ind=-1
cur_thread=0
cur_sec=0

# loop to check threads
for i in `mysql -h "127.0.0.1" -u "root" "-proot" "information_schema" -e "select trx_mysql_thread_id,TIMESTAMPDIFF(SECOND,trx_started,NOW()) from innodb_trx;" -N`; do
  ind=`expr $ind + 1`

  row=`expr $ind / 2`
  col=`expr $ind % 2`

  if [ $col == 0 ]; then
    cur_thread=$i
    continue
  fi

  if [ $col == 1 ]; then
    cur_sec=$i
    if [ $cur_sec -gt $sec ]; then
      if [ $is_kill == 0 ]; then
        echo "`date '+%Y-%m-%d %H:%M:%S'` --------thread warn: thread id: " $cur_thread " started: " $cur_sec " seconds, rows: " $row " col: " $col
      else
        mysql -h "127.0.0.1" -u "root" "-proot" "information_schema" -e "kill $cur_thread" &
        echo "`date '+%Y-%m-%d %H:%M:%S'` !!!!----thread killed: thread id: " $cur_thread " started: " $cur_sec " seconds, rows: " $row " col: " $col
      fi
    fi
  fi
done
