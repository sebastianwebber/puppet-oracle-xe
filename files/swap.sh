#!/bin/bash -x

if [ ! -e /proc/meminfo ]
then
  exit 42
fi

SWAP=`grep SwapTotal /proc/meminfo | sed 's/[^0-9]//g'`
TOTAL=`grep MemTotal /proc/meminfo | sed 's/[^0-9]//g'`

BUFFER=5000

GLOBAL_MIN_SWAP=$[2097152+BUFFER]
RAM_MIN_SWAP=$[TOTAL*2+BUFFER]
MKSWAP_MIN=41

SWAP_TO_CREATE="none"

if [ "$SWAP" -lt "$GLOBAL_MIN_SWAP" ]
then
  if [ "$SWAP" -lt "$RAM_MIN_SWAP" ]
  then
    if [ "$RAM_MIN_SWAP" -lt "$GLOBAL_MIN_SWAP" ]
    then
      SWAP_TO_CREATE=$[RAM_MIN_SWAP-SWAP]
    else
      SWAP_TO_CREATE=$[GLOBAL_MIN_SWAP-SWAP]
    fi
  fi
fi

if [ $MKSWAP_MIN -gt $SWAP_TO_CREATE ]; then
  SWAP_TO_CREATE=$MKSWAP_MIN
fi


if [ "$SWAP" == "none" ]
then
  exit 0
else
  TMP='/var/oracle-xe.swapfile'

  dd if=/dev/zero of=$TMP bs=1024 count=$SWAP_TO_CREATE
  chmod 0600 $TMP
  mkswap $TMP
  swapon -a $TMP
fi
