#!/bin/bash

source "$(dirname $0)"/webgraph_config.sh

DIR=$(dirname $0)/law-$LAW_VERSION

_CLASSPATH=$DIR/law-$LAW_VERSION.jar:$(ls $DIR/deps/*.jar | tr '\n' ':')
if [ -n "$CLASSPATH" ]; then
    _CLASSPATH=$CLASSPATH:$_CLASSPATH
fi

# heuristics to run law with 80% of available RAM
MEMMB=$(free -m | perl -ne 'do { print int($1*.8); last } if /(\d+)/')
JAVA_OPTS=-Xmx${MEMMB}m


case "$1" in
    it.unimi.dsi.law.rank.PageRankParallelGaussSeidel | it.unimi.dsi.big.law.rank.PageRankParallelGaussSeidel)
        JAVA_OPTS="$JAVA_OPTS -server -Xss256K -XX:PretenureSizeThreshold=512M -XX:MaxNewSize=$(($MEMMB/3))m \
          -XX:+UseNUMA -XX:+UseTLAB -XX:+ResizeTLAB \
          -XX:+UseConcMarkSweepGC -XX:CMSInitiatingOccupancyFraction=99 -XX:+UseCMSInitiatingOccupancyOnly \
          -verbose:gc -Xloggc:gc.log"
    ;;
esac

set -x
time java $JAVA_OPTS -cp $_CLASSPATH "$@"




