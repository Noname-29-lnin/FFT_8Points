# ///////////////////////////////////////////////////////////////
# The makefile create by Dong
# ///////////////////////////////////////////////////////////////
#==============================
# Simulation Configuration
#==============================
TOPMODULE       ?= top
INC_DIR         ?= ./build
LIB_DIR         ?= ./
RADIX           ?= binary

LIB_INC          = $(shell find $(LIB_DIR) -type f -name "*.svh" -exec dirname {} \; | sort -u)
LIB_FLAG         = $(foreach d, $(LIB_INC), +incdir+$(d))
TB_NAME          = tb_$(TOPMODULE)
INC_WORK         = $(INC_DIR)/QuestaSim

-include config.mk

# Load Targets
.PHONY: load view
load:
	@echo "Saving configuration..."
	@echo "TOPMODULE=$(TOPMODULE)" > config.mk
	@echo "INC_DIR=$(INC_DIR)" >> config.mk
	@echo "LIB_DIR=$(LIB_DIR)" >> config.mk
	@echo "RADIX=$(RADIX)" >> config.mk
	@echo "-> Saved to config.mk"
	@cat config.mk

view:
	@cat config.mk
# Targets
.PHONY: all all_wave all_cov compile compile_cover run run_cover wave gen_cov gen_html gen_view clean clear_temp help 

all: compile run clear_temp
all_wave: compile run wave clear_temp
all_cov: compile_cover run_cover clear_temp gen_cov gen_html

compile:
	@echo "-> mkdir..."
	@mkdir -p $(INC_WORK) \
		&& echo "<Pass> mkdir $(INC_WORK)" \
		|| echo "<False> mkdir $(INC_WORK)"
	@echo "TB_NAME: $(TB_NAME)"
	@echo "INC_DIR: $(INC_DIR)"
	@echo "LIB_DIR: $(LIB_DIR)"
	@echo "RADIX: 	$(RADIX)" 
	@echo "FLIST content:"
	@cat $(INC_DIR)/flist.f
	@echo " "
	@echo "LIB_INC directories:"
	@for dir in $(LIB_INC); do \
		echo "  $$dir"; \
	done
	@echo "LIB_FLAG: $(LIB_FLAG)"
	@echo " "
	@find $(LIB_DIR) -name "*.svh" 2>/dev/null | while read file; do \
		echo "  $$file"; \
	done || echo "  No .svh files found"
	@echo " "
	@echo "-> compile..."
	@vlib $(INC_WORK)/work > /dev/null 2>&1
	@vmap work $(INC_WORK)/work > /dev/null 2>&1
	@vlog $(LIB_FLAG) -f $(INC_DIR)/flist.f | tee $(INC_WORK)/compile.log; \
	if [ $$? -ne 0 ]; then \
		echo "<False> compile $(TOPMODULE)"; \
		exit 1; \
	else \
		echo "<Pass> compile $(TOPMODULE)"; \
	fi

compile_cover:
	@echo "-> mkdir..."
	@mkdir -p $(INC_WORK) \
		&& echo "<Pass> mkdir $(INC_WORK)" \
		|| echo "<False> mkdir $(INC_WORK)"
	@echo "-> compile (coverage mode)..."
	@vlib $(INC_WORK)/work > /dev/null 2>&1
	@vmap work $(INC_WORK)/work > /dev/null 2>&1
	@vlog +cover=bcesft $(LIB_FLAG) -f $(INC_DIR)/flist.f | tee $(INC_WORK)/compile.log
	@vlog $(LIB_FLAG) -f $(INC_DIR)/flist.f | tee $(INC_WORK)/compile.log; \
	if [ $$? -ne 0 ]; then \
		echo "<False> compile $(TOPMODULE)"; \
		exit 1; \
	else \
		echo "<Pass> compile $(TOPMODULE)"; \
	fi

run:
	@echo "-> Copy modelsim.ini..."
	@cp ./modelsim.ini $(INC_WORK)
	@if ls ./*.vcd > /dev/null 2>&1; then \
		mv ./tb_$(TOPMODULE).vcd $(INC_WORK)/ 2>/dev/null; \
		echo "<Pass> moved .vcd files to $(INC_WORK)"; \
	else \
		echo "<Info> no .vcd files found in current directory"; \
	fi
	@echo "-> run..."
	@vsim -lib $(INC_WORK)/work -debugDB -l $(INC_WORK)/$(TB_NAME).log \
		-voptargs=+acc -assertdebug -c $(TB_NAME) \
		-wlf $(INC_WORK)/$(TB_NAME).wlf \
		-do "cd $(INC_WORK); log -r /*; run -all;"

run_cover:
	@echo "-> Copy modelsim.ini..."
	@cp ./modelsim.ini $(INC_WORK)
	@echo "-> Move .vcd..."
	@if ls ./*.vcd > /dev/null 2>&1; then \
		mv ./tb_$(TOPMODULE).vcd $(INC_WORK)/ 2>/dev/null; \
		echo "<Pass> moved .vcd files to $(INC_WORK)"; \
	else \
		echo "<Info> no .vcd files found in current directory"; \
	fi
	@echo "-> run_cover..."
	@vsim -coverage -lib $(INC_WORK)/work -l $(INC_WORK)/$(TB_NAME).log \
		-voptargs='+cover=bcesft' -assertdebug -c $(TB_NAME) \
		-wlf $(INC_WORK)/$(TB_NAME).wlf \
		-do "coverage save -onexit $(INC_WORK)/$(TB_NAME).ucdb; cd $(INC_WORK); log -r /*; run -all;"

wave:
	@echo "-> open waveform..."
	@vsim -i -view $(INC_WORK)/$(TB_NAME).wlf -do "add wave vsim:/$(TB_NAME)/*; radix -$(RADIX)" &
	@echo "<Pass> open waveform for $(TB_NAME)"

gen_cov:
	@echo "-> generate coverage text reports..."
	@mkdir -p $(INC_WORK)/coverage \
		&& echo "<Pass> mkdir $(INC_WORK)/coverage" \
		|| echo "<False> mkdir $(INC_WORK)/coverage"
	@cd $(INC_WORK) && \
	vcover merge IP.ucdb *.ucdb > /dev/null 2>&1 && \
	vcover report IP.ucdb -output coverage/summary_report.txt && \
	vcover report -zeros -details -code bcesft -annotate -All -codeAll IP.ucdb -output coverage/detail_report.txt \
		&& echo "<Pass> generate coverage reports" \
		|| echo "<False> generate coverage reports"

gen_html:
	@echo "-> generate HTML coverage report..."
	@mkdir -p $(INC_WORK)/coverage \
		&& echo "<Pass> mkdir $(INC_WORK)/coverage" \
		|| echo "<False> mkdir $(INC_WORK)/coverage"
	@cd $(INC_WORK) && \
	vcover merge IP.ucdb *.ucdb > /dev/null 2>&1 && \
	vcover report -zeros -details -code bcesft -annotate -testhitdataAll -html IP.ucdb \
		&& echo "<Pass> generate HTML report" \
		|| echo "<False> generate HTML report"

gen_view:
	@echo "-> open HTML coverage report..."
	xdg-open "$(INC_WORK)/covhtmlreport/index.html" >/dev/null 2>&1 

clear_temp:
	@rm -rf ./*.vcd ./*.log

clean:
	@echo "-> clean..."
	@rm -rf $(INC_WORK)/work $(INC_WORK)/vsim.dbg $(INC_WORK)/*.ini $(INC_WORK)/*.log $(INC_WORK)/*.vcd \
		$(INC_WORK)/*.wlf $(INC_WORK)/transcript $(INC_WORK)/*.ucdb $(INC_WORK)/coverage
	@echo "<Pass> clean $(TOPMODULE)"

help:
	@echo ""
	@echo "****************************************"
	@echo "** QuestaSim Makefile Help Menu"
	@echo "****************************************"
	@echo ""
	@echo " TOPMODULE : The name of the top-level module to simulate"
	@echo " INC_DIR   : The directory path containing all design source files"
	@echo " RADIX     : The waveform display radix (e.g., binary, hex, unsigned, decimal)"
	@echo ""
	@echo "****************************************"
	@echo "** Available Targets"
	@echo "****************************************"
	@echo "** make clean      : Remove all compiled libraries and simulation outputs"
	@echo "** make build      : Compile and elaborate the design"
	@echo "** make build_cov  : Compile and elaborate the design with coverage enabled"
	@echo "** make run        : Run the simulation in console mode"
	@echo "** make run_cov    : Run the simulation in coverage mode"
	@echo "** make all        : Build and run simulation (non-coverage)"
	@echo "** make all_cov    : Build and run simulation with coverage"
	@echo "** make wave       : Launch waveform viewer (GUI mode)"
	@echo "** make gen_cov    : Merge UCDB files and generate a text-based coverage report"
	@echo "** make gen_html   : Merge UCDB files and generate an HTML coverage report"
	@echo "** make gen_view   : Open the HTML coverage report in the default web browser"
	@echo "****************************************"
	@echo ""
