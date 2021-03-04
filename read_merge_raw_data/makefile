TASK_DIR := $(shell dirname $(realpath $(lastword $(MAKEFILE_LIST))))
IN_DIR := ../raw_data

include ../config.mk

# Inputs
TASK_CONFIG = $(TASK_DIR)/hand/config.yaml
CONFIGS = $(TASK_CONFIG)
TASK_FNS = $(wildcard $(TASK_DIR)/R/*.R)
FNS = $(GENERAL_FNS) $(TASK_FNS)
IN_FILES = $(wildcard $(IN_DIR)/*.dta)

# Outputs
OUT_FILES = $(addprefix $(OUT_DIR)/,\
	$(addsuffix .feather, rain_temp crosswalk))

## rain_temp_and_crosswalk : Read/merge rain/temperature files as well as the crosswalk.
.PHONY : rain_temp_and_crosswalk
rain_temp_and_crosswalk : $(OUT_FILES)

$(OUT_FILES) : $(SRC) $(IN_FILES) $(FNS) $(CONFIGS)
	$(R_script) --vanilla $<

## clean			 : Remove auto-generated files.
.PHONY : clean
clean :
	rm -r $(OUT_DIR)

## variables		: List variables.
.PHONY : variables
variables :
	@echo PROJECT_DIR: $(PROJECT_DIR)
	@echo TASK_DIR: $(TASK_DIR)
	@echo OUT_FILES : $(OUT_FILES)
	@echo SRC: $(SRC)
	@echo IN_FILES: $(IN_FILES)
	@echo FNS: $(FNS)
	@echo CONFIGS: $(CONFIGS)
	@echo R_script : $(R_script)

.PHONY : help
help : makefile
	@sed -n 's/^##//p' $<
