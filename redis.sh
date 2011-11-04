#!/bin/bash

function start {
    redis-server config/redis.conf
    echo "start"
}

function stop {
    kill `cat tmp/redis.pid`
    echo "stop"
}

function restart {
    stop
    start
#    echo "restart"
}

case "$1" in
  start)
    start
    ;;
  stop)
    stop
    ;;
  restart)
    restart
    ;;
  *)
    echo $"Usage: $0 {start|stop|restart}"
    exit 1
    ;;
esac
