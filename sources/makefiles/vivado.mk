# makefile vivado
# melvin.alvarado
# reference https://www.itsembedded.com/dhd/vivado_sim_3/

SRC_VERIF ?= tb.v
SRC_RTL ?= dut.v
TB_TOP ?= tb

DEBUG ?= 1
COMP_RTL_OPT ?= -sv -L uvm --incr
COMP_VERIF_OPT ?= -sv -L uvm --incr
SIM_OPT ?=
ELAB_OPT ?= -timescale 1ns/1ns
DEFINE ?=

ALL_SV_FILES := $(shell find $(PROJ) -name '*.v*' -o -name "*.sv*" )

SRC_RTL_P = $(addprefix $(PROJ)/rtl/,$(SRC_RTL))
SRC_RTL_EXTRA ?=
SRC_VERIF_P = $(addprefix $(PROJ)/dv/,$(SRC_VERIF))
DEFINE_OPT = $(addprefix -d ,$(DEFINE))

POST_PROC = python3 $(COMMON)/utils/test_status.py

ifeq ($(DEBUG),1)
	ELAB_OPT += -debug wave
endif

CYAN ='\033[1;36m'
NC ='\033[0m' # No Color
define LOG
	@echo
    @echo -e $(CYAN)--- $(1)$(NC)
endef

#=============================================================#
#==== Main targets ====#
.PHONY : simulate
simulate : $(TB_TOP).wdb

.PHONY : elaborate
elaborate : .elab.timestamp

.PHONY : compile
compile : .comp.timestamp

#==== COVERAGE REPORT ====#
coverage: xsim.covdb
	$(call LOG,Generating coverage report)
	xcrg -report_format html

#==== WAVEFORM DRAWING ====#
.PHONY : waves
waves : $(TB_TOP).wdb
	$(call LOG,Openning waves)
	xsim --gui $(TB_TOP).wdb

#==== SIMULATION ====#
.PHONY: $(TB_TOP).wdb
$(TB_TOP).wdb: .elab.timestamp
	@rm -f xsim.log
	$(call LOG,Simulation)
	xsim $(TB_TOP) --stats -tclbatch $(CODE)/common/utils/xsim.tcl $(SIM_OPT)
	$(POST_PROC)

#==== ELABORATION ====#
.elab.timestamp: .comp.timestamp
	$(call LOG,Elaborating)
	xelab $(TB_TOP) -s $(TB_TOP) $(ELAB_OPT) $(DEFINE_OPT)
	touch .elab.timestamp

#==== COMPILING SYSTEMVERILOG ====#
.comp.timestamp: $(ALL_SV_FILES)
	@echo $(ALL_SV_FILES)
	$(call LOG,Compiling source files)
	xvlog $(COMP_RTL_OPT) $(SRC_RTL_EXTRA) $(SRC_RTL_P) -i $(PROJ)/rtl $(DEFINE_OPT)
	xvlog $(COMP_VERIF_OPT) $(SRC_RTL_EXTRA) $(SRC_VERIF_P) -i $(PROJ)/dv -i $(PROJ)/rtl $(DEFINE_OPT)
	touch .comp.timestamp

.PHONY: clean
clean:
	-rm -rf *backup* *.log *.pb *.jou *.vcd *.wdb xsim.dir xsim.covdb
	-rm .elab.timestamp .comp.timestamp
