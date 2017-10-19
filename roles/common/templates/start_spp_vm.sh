#!/bin/bash

SEC_ID=$1

sudo $(dirname $0)/src/vm/x86_64-native-linuxapp-gcc/spp_vm \
  -c 0x03 \
  -n 4 \
  --proc-type=primary \
  -- \
  -p 0x01 \
  -n ${SEC_ID} \
  -s 192.168.122.1:6666
