# makefile
# project: unpacker
# melvin.alvarado

SRC_VERIF = unpacker_pkg.sv unpacker_tb_top.sv
SRC_RTL = unpacker.v
TB_TOP = unpacker_tb_top
DEFINE = ASSERT_ON COVERAGE_ON

SIM_OPT = --testplusarg UVM_TESTNAME=unpacker_test
SIM_OPT += -sv_seed random

include $(CODE)/makefiles/vivado.mk
