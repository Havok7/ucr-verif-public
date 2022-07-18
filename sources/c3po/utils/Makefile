# makefile
# project: c3po
# melvin.alvarado

TEST ?= c3po_pkt_all_test
SEED ?= random

SRC_VERIF = c3po_pkg.sv c3po_tb_top.sv
SRC_RTL = c3po_regs.v c3po.v
TB_TOP = c3po_tb_top
# DEFINE = ASSERT_ON COVERAGE_ON

SRC_RTL_EXTRA = -i $(CODE)/control/rtl -i $(CODE)/regs/rtl -i $(CODE)/unpacker2/rtl -i $(CODE)/counter/rtl $(COMMON)/rtl/common.vh

SIM_OPT = --testplusarg UVM_TESTNAME=$(TEST)
SIM_OPT += -sv_seed $(SEED)

include $(CODE)/makefiles/vivado.mk
