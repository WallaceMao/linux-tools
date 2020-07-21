#!/bin/bash

while :
do
  statusCode=$(curl -m 2 -s -o /dev/null -w "%{http_code}" http://localhost:9091/wx-contact/public/status/health)
  if [ $statusCode == '200' ]
  then
    echo "`date '+%Y-%m-%dT%H:%M:%S'` status: $statusCode" >> /root/logs/wxcs-monitor-verbose.log
  else
    echo "`date '+%Y-%m-%dT%H:%M:%S'` status: $statusCode trying to restart" >> /root/logs/wxcs-monitor-restart.log
    wxcs stop
    wxcs start
  fi
  sleep 10
done
