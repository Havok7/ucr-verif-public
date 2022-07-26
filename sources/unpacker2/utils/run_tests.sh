#!/usr/bin/bash

TESTS=(
    unpacker_pkt_small_test
    unpacker_pkt_mid_test
    unpacker_pkt_large_test
    unpacker_pkt_all_simple_test
    unpacker_pkt_all_val_test
    unpacker_pkt_all_reset_test
    unpacker_pkt_corner_sizes_test
)

for TEST in ${TESTS[@]}; do
    make -f $PROJ/utils/Makefile TEST=$TEST
done
