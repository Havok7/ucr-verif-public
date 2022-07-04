# makefile
# project: regs
# melvin.alvarado

SRC_VERIF = regs_pkg.sv regs_tb_top.sv
SRC_RTL = regs.v
SRC_RTL_EXTRA = $(COMMON)/rtl/common.vh
TB_TOP = regs_tb_top
#DEFINE = ASSERT_ON COVERAGE_ON
SIM_OPT = --testplusarg UVM_TESTNAME=regs_test
include $(CODE)/makefiles/vivado.mk