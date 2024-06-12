# This Makefile is designed to traverse each subdirectory and execute its own Makefile.
#
# Usage: make
# 
# Maintainer:
#   Qucheng Jiang
# 

# Define SUBDIRS variable to store a list of all subdirectories using wildcard function.
SUBDIRS := $(filter-out $(wildcard log*/), $(wildcard */))

# Declare all subdirectories as phony targets to prevent conflicts with directory names.
.PHONY: all $(SUBDIRS)

# Define 'all' target which depends on all subdirectories.
all: $(SUBDIRS)
	echo all

# Define a rule for each subdirectory.
$(SUBDIRS):
	echo $@
	$(MAKE) -C $@ --file ../makefile.subdir.mak
