# makefile
# project: control-fsm
# melvin.alvarado

SRC_VERIF = control_pkg.svh control_tb_top.sv

# SRC_RTL = control_original.v
SRC_RTL = control.v
TB_TOP = control_tb_top
DEFINE = ASSERT_ON COVERAGE_ON

SIM_OPT = --testplusarg UVM_TESTNAME=control_test -sv_seed 120

include $(CODE)/makefiles/vivado.mk

tests:
	$(PROJ)/utils/test_runner.sh $(arg1) 

coverage_tests: xsim.covdb
	$(call LOG,Generating coverage report)
	xcrg -report_format html -dir dir-*

clean_tests: 
	rm -R dir-*