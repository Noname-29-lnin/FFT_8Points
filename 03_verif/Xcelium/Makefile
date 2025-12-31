TOPMODULE   	?= top
INC_DIR     	?= ./
LIB_DIR     	?= ./

DEF_GATELEVEL 	?=  
DEF_ANNOTATION 	?=  
DEF_WAVE		?=shm

TB_NAME      	= tb_$(TOPMODULE)
WORK_DIR     	= $(INC_DIR)/Xcelium
FLIST        	= $(INC_DIR)/flist.f
LIB_INC      	= $(shell find $(LIB_DIR) -type f -name "*.svh" -exec dirname {} \; | sort -u)
NAME_GATELEVEL	= $(DEF_GATELEVEL)
NAME_ANNOTATION = $(DEF_ANNOTATION)
NAME_WAVE		= $(WORK_DIR)/$(TB_NAME).$(DEF_WAVE)
#============================================================
# Targets
#============================================================
-include config.mk

# Load Targets
.PHONY: load
load:
	@echo "Saving configuration..."
	@echo "TOPMODULE=$(TOPMODULE)" > config.mk
	@echo "INC_DIR=$(INC_DIR)" >> config.mk
	@echo "LIB_DIR=$(LIB_DIR)" >> config.mk
	@echo "DEF_GATELEVEL=$(DEF_GATELEVEL)" >> config.mk
	@echo "DEF_ANNOTATION=$(DEF_ANNOTATION)" >> config.mk
	@echo "DEF_WAVE=$(DEF_WAVE)" >> config.mk
	@echo "-> Saved to config.mk"
	@cat config.mk

.PHONY: all all_wave create view compile run gui clean kill help
all: create compile run
all_wave: create compile run gui
.PHONY: all_gatelevel all_annotation compile_gatelevel compile_annotation
all_gatelevel: create compile_gatelevel run
all_annotation: create compile_annotation run

create:
	@echo "-> Creating work directory..."
	@mkdir -p $(INC_WORK) \
		&& echo "<Pass> mkdir $(INC_WORK)" \
		|| echo "<False> mkdir $(INC_WORK)"
	@echo "TB_NAME: $(TB_NAME)"
	@echo "INC_DIR: $(INC_DIR)"
	@echo "LIB_DIR: $(LIB_DIR)"
	@echo "FLIST content:"
	@cat $(FLIST)
	@echo " "
	@echo "LIB_INC directories:"
	@for dir in $(LIB_INC); do \
		echo "  $$dir"; \
	done
	@echo " "
	@find $(LIB_DIR) -name "*.svh" 2>/dev/null | while read file; do \
		echo "  $$file"; \
	done || echo "  No .svh files found"
	@echo " "
	@echo "DEF_GATELEVEL = $(NAME_GATELEVEL)"
	@echo "DEF_ANNOTATION = $(NAME_ANNOTATION)"
	@echo " "

view:
	@echo "Open config.mk..."
	@cat ./config.mk

compile:
	@echo "-> compile..."
	@xrun +xm64bit -sv -f $(FLIST) \
	     -top $(TB_NAME) \
	     -access +rwc \
	     -clean \
	     -log $(WORK_DIR)/compile.log \
	     +nctimescale+1ns/1ps \
		 +ntb_random_seed=automatic \
	     -allowredefinition \
	     -v93 \
	     && echo "<Pass> compile $(TB_NAME)" || (echo "<False> compile $(TB_NAME)" && exit 1)
	@rm -rf ./*.vcd

compile_gatelevel: 
	@echo "-> compile for gate-level-netlist without .sdf file..."
	@xrun +xm64bit -sv -define $(NAME_GATELEVEL) -f $(FLIST) \
	     -top $(TB_NAME) \
	     -access +rwc \
	     -clean \
	     -log $(WORK_DIR)/compile_gatelevel.log \
	     +nctimescale+1ns/1ps \
		 +ntb_random_seed=automatic \
	     -allowredefinition \
	     -v93 \
	     && echo "<Pass> compile_gatelevel $(TB_NAME)" || (echo "<False> compile_gatelevel $(TB_NAME)" && exit 1)
	@rm -rf ./*.vcd

compile_annotation: 
	@echo "-> compile for gate-level-netlist and .sdf file..."
	@xrun +xm64bit -sv -define $(NAME_GATELEVEL) -define $(NAME_ANNOTATION) -f $(FLIST) \
	     -top $(TB_NAME) \
	     -access +rwc \
	     -clean \
	     -log $(WORK_DIR)/compile_annotation.log \
	     +nctimescale+1ns/1ps \
		 +ntb_random_seed=automatic \
	     -allowredefinition \
	     -v93 \
	     && echo "<Pass> compile_annotation $(TB_NAME)" || (echo "<False> compile_annotation $(TB_NAME)" && exit 1)
	@rm -rf ./*.vcd

run:
	@echo "-> Move file $(TB_NAME).shm"
	@rm -rf $(WORK_DIR)/$(TB_NAME).shm
	@mv $(TB_NAME).shm $(WORK_DIR) \
	     && echo "<Pass> Move $(TB_NAME).shm to $(WORK_DIR)/$(TB_NAME)" || (echo "<False> Move $(TB_NAME).shm to $(WORK_DIR)/$(TB_NAME)" && exit 1)
	@echo "-> Copy Xcelium..."
	@cp -r ./xcelium.d $(WORK_DIR) \
		&& echo "<Pass> Copy xcelium.d to $(WORK_DIR)/xcelium.d" || (echo "<False> Copy xcelium.d to $(WORK_DIR)/xcelium.d" && exit 1)

gui:
	@echo "-> SIMULATION WITH SIMVISION..."
	@simvision -waves $(NAME_WAVE) &> /dev/null &

clean:
	@echo "-> Cleaning Xcelium files..."
	@rm -rf INCA_libs xcelium.d .xrun* *.history *.log *.key *.shm .simvision
	@echo "<Pass> clean done"

cleanall:
	@echo "-> Clear all..."
	@rm -rf INCA_libs xcelium.d .xrun* *.history *.log *.key $(TB_NAME).shm simvision* work .simvision
	@echo "-> Remove $(WORK_DIR)..."
	@rm -rf $(WORK_DIR)
	@echo "<Pass> clean done"

kill:
	@echo "-> KILLING SimVision"
	pkill -f simvision

help:
	@echo "===================================================================="
	@echo "                       XCELIUM MAKEFILE - Optimized"
	@echo "===================================================================="
	@echo " Basic Commands:"
	@echo "   make load            → Save TOPMODULE, INC_DIR, and options to config.mk"
	@echo "   make all             → Compile RTL only (generate compile.log)"
	@echo "   make all_wave        → Compile RTL, run simulation, and open SimVision"
	@echo "   make gui             → Open SimVision using the last generated waveform"
	@echo "   make clean           → Remove all temporary Xcelium build files"
	@echo "   make cleanall        → Remove all build files and the work directory"
	@echo "   make kill            → Force-close any running SimVision instance"
	@echo "--------------------------------------------------------------------"
	@echo " Gate-Level Simulation:"
	@echo "   make all_gatelevel   → Compile and run gate-level without SDF annotation"
	@echo "   make all_annotation  → Compile and run gate-level with SDF annotation"
	@echo "   (Uses macros '$(DEF_GATELEVEL)' and '$(DEF_ANNOTATION)')"
	@echo "--------------------------------------------------------------------"
	@echo " Notes:"
	@echo "   - Define macros for gate-level:      $(DEF_GATELEVEL)"
	@echo "   - Define macros for SDF annotation:  $(DEF_ANNOTATION)"
	@echo "   - Ensure flist.f lists RTL, gate-level netlist, and library files."
	@echo "===================================================================="
