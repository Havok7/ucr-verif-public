#!/usr/bin/bash

TESTS=(
    c3po_pkt_all_simple_test
    c3po_pkt_all_val_test
    c3po_pkt_all_reset_test
    c3po_pkt_cfg_port_enable_test
    c3po_pkt_cfg_port_id_test
)

for TEST in ${TESTS[@]}; do
    make -f $PROJ/utils/Makefile TEST=$TEST
done
