# Author:      Noname-29-lnin
# Version:     v0.0.3

# ===========================
# Global Configuration
# ===========================
MAIN_TEST        ?= main
SRC_FILE         ?= flist.f
BUILD_DIR        ?= build
REPORT_DIR       ?= Reports
VALUE_SERIAL     ?= 2
VALUE_PARALLEL   ?= 2
ANALYSIS_NAME    ?= serial
NAME_TEST        ?= slipt_subarr
DIR_TEST         ?= example

-include config.mk

# ===========================
# Static Variables
# ===========================
S_MAIN_TEST        	= $(MAIN_TEST)
S_SRC_FILE         	= $(SRC_FILE)
S_BUILD_FILE       	= $(BUILD_DIR)
S_REPORT_FILE      	= $(REPORT_DIR)
S_VALUE_SERIAL     	= $(VALUE_SERIAL)
S_VALUE_PARALLEL   	= $(VALUE_PARALLEL)
S_ANALYSIS_NAME    	= $(ANALYSIS_NAME)
S_NAME_TEST			= $(NAME_TEST)
S_DIR_TEST			= $(DIR_TEST)

# ===========================
# Tools
# ===========================
ANALYSIS_DIR   	:= $(S_REPORT_FILE)/ANALYSIS_DIR
COMPILE_DIR    	:= $(S_REPORT_FILE)/COMPILE_REPORT

TARGET         := $(MAIN_TEST)
CXX            := g++
CXXFLAGS       := -Wall -O2 -std=c++17
LDFLAGS        := -pthread

MEM_LEAK       := valgrind
CACHE_MISS     := perf

# ===========================
# Load/Save Config Targets
# ===========================
.PHONY: load view help clean run all

load:
	@echo "Saving configuration..."
	@echo "MAIN_TEST=$(MAIN_TEST)" > config.mk
	@echo "SRC_FILE=$(SRC_FILE)" >> config.mk
	@echo "BUILD_DIR=$(BUILD_DIR)" >> config.mk
	@echo "REPORT_DIR=$(REPORT_DIR)" >> config.mk
	@echo "VALUE_SERIAL=$(VALUE_SERIAL)" >> config.mk
	@echo "VALUE_PARALLEL=$(VALUE_PARALLEL)" >> config.mk
	@echo "ANALYSIS_NAME=$(ANALYSIS_NAME)" >> config.mk
	@echo "NAME_TEST=$(NAME_TEST)" >> config.mk
	@echo "DIR_TEST=$(DIR_TEST)" >> config.mk
	@echo "-> Saved to config.mk"
	@cat config.mk

view:
	@echo "Opening config.mk..."
	@cat config.mk

# ===========================
# Source File Handling
# ===========================
ifeq ($(wildcard $(S_SRC_FILE)),)
    SRC_LIST := $(S_MAIN_TEST).cpp
else
    SRC_LIST := $(shell cat $(S_SRC_FILE)) $(S_MAIN_TEST).cpp
endif
OBJ_LIST := $(addprefix $(S_BUILD_FILE)/, $(SRC_LIST:.cpp=.o))

# ===========================
# Build Targets
# ===========================
all: clean run

$(TARGET): $(OBJ_LIST)
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $^ -o $@

$(S_BUILD_FILE)/%.o: %.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

run: $(TARGET)
	./$(TARGET) $(S_VALUE_SERIAL) $(S_VALUE_PARALLEL) | tee $(COMPILE_DIR)/$(S_ANALYSIS_NAME).log

clean:
	rm -rf $(S_BUILD_FILE) $(TARGET)
	@mkdir -p $(COMPILE_DIR)
	

clear:
	rm -rf $(S_BUILD_FILE) $(TARGET) $(REPORT_DIR)

# ===========================
# Unit Test Configuration
# ===========================
.PHONY: test test_clean

# File test
TEST_CPP := $(S_DIR_TEST)/$(S_NAME_TEST).cpp
TEST_OBJ := $(S_BUILD_FILE)/$(S_DIR_TEST)/$(S_NAME_TEST).o
TEST_BIN := $(S_DIR_TEST)/$(S_NAME_TEST)
TEST_LOG := $(S_DIR_TEST)/$(S_NAME_TEST).log

# ===========================
# Reuse object files from src/
# (exclude MAIN_TEST.cpp)
# ===========================
SRC_ONLY := $(filter-out $(S_MAIN_TEST).cpp, $(SRC_LIST))
SRC_OBJ  := $(addprefix $(S_BUILD_FILE)/, $(SRC_ONLY:.cpp=.o))

# ===========================
# Build & Run Test
# ===========================
test: $(TEST_BIN)
	@echo "=== RUN TEST: $(S_NAME_TEST) ==="
	./$(TEST_BIN) | tee $(TEST_LOG)

$(TEST_BIN): $(SRC_OBJ) $(TEST_OBJ)
	@echo "=== LINK TEST ==="
	$(CXX) $(CXXFLAGS) $(LDFLAGS) $^ -o $@

# ===========================
# Compile test object
# ===========================
$(S_BUILD_FILE)/$(S_DIR_TEST)/%.o: $(S_DIR_TEST)/%.cpp
	@mkdir -p $(dir $@)
	$(CXX) $(CXXFLAGS) -c $< -o $@

# ===========================
# Clean test only
# ===========================
test_clean:
	rm -f $(TEST_BIN) $(TEST_OBJ) $(TEST_LOG)


# ===========================
# Analysis Tools
# ===========================
checkmemory: $(TARGET)
	@mkdir -p $(ANALYSIS_DIR)/checkmemory
	@echo "=== Checking memory usage with Valgrind Massif ==="
	$(MEM_LEAK) --tool=massif --stacks=yes \
		--massif-out-file=$(ANALYSIS_DIR)/checkmemory/$(S_ANALYSIS_NAME).out \
		./$(TARGET) $(S_VALUE_SERIAL) $(S_VALUE_PARALLEL)
	ms_print $(ANALYSIS_DIR)/checkmemory/$(S_ANALYSIS_NAME).out > $(ANALYSIS_DIR)/checkmemory/$(S_ANALYSIS_NAME).log
	@echo "=== PEAK MEMORY USAGE ==="
	@grep "mem_heap_B" $(ANALYSIS_DIR)/checkmemory/$(S_ANALYSIS_NAME).out | sort -nr | head -1

checkcachemiss: $(TARGET)
	@mkdir -p $(ANALYSIS_DIR)/checkcachemiss
	@echo "=== Checking cache performance ==="
	sudo $(CACHE_MISS) stat -e cache-references,cache-misses \
		./$(TARGET) $(S_VALUE_SERIAL) $(S_VALUE_PARALLEL) \
		2>&1 | tee $(ANALYSIS_DIR)/checkcachemiss/$(S_ANALYSIS_NAME).log

# ===========================
# Help
# ===========================
help:
	@echo "Targets available:"
	@echo "  all             - clean and run"
	@echo "  run             - compile & execute"
	@echo "  clean           - remove build artifacts"
	@echo "  load            - save current config to config.mk"
	@echo "  view            - print config.mk"
	@echo "  checkmemory     - run valgrind massif"
	@echo "  checkcachemiss  - perf cache miss report"
