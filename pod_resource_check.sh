#!/bin/bash

usage(){ echo "Usage: $0 -n <string> -l <string>" 1>&2; exit 1; }

# default params
ns=
se=

# parse option and params
while getopts ":n:l:" o; do
  case "${o}" in
    n)
      ns=${OPTARG}
      ;;
    l)
      se=${OPTARG}
      ;;
    *)
      usage
      ;;
  esac
done

if [ -z $ns ]; then
    usage
    exit 1
fi
if [ -z $se ]; then
    usage
    exit 1
fi

for i in `kubectl -n $ns get pod --selector=$se | grep -v NAME | awk '{print $1}'`; do
  echo "`date '+%Y-%m-%dT%H:%M:%S'`|$ns|$se|`kubectl -n $ns top pod $i | grep -v NAME`"
done

exit 0
