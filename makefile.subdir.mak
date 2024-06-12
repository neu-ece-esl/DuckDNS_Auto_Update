# Makefile to update DuckDNS with the current IP address and log the activity.
#
# Usage: 
#   Don't run this makefile directly. 
#   This is only used for guiding make to go over each subfolder. 
#   Use `makefile` with `make` instead.
#

# Read content in file: domain, token.
# Save into var: duck_domain, duck_token
Duck_Domain := $(shell cat domain)
Duck_Token := $(shell cat token)

# Get current IP address based on IF_MAC
# IP_IF_MAC_ADDR -> IP_INTERFACE (name) -> IP_ADDR
IP_IF_MAC_ADDR ?= $(shell cat if_mac_addr)
# IP_INTERFACE := $(shell ../find_IF_using_MAC_addr $(IP_IF_MAC_ADDR))
IP_INTERFACE := $(if $(IP_INTERFACE),$(IP_INTERFACE),$(shell cat interface))
IP_ADDR := $(shell ip addr show $(IP_INTERFACE) | grep 'inet ' | awk '{{print $$2}}' | cut -d'/' -f1 | head -n 1)

# Combine the obtained details into a URL string for DuckDNS update
Duck_URL := https://www.duckdns.org/update?domains=$(Duck_Domain)&token=$(Duck_Token)&ip=$(IP_ADDR)

# Define place to save log file.
# Default location: ./log/<domain_name>/<datetime>.log
Log_Save_Path ?= ../log/$(Duck_Domain)/$(shell date +'%Y-%m-%d')
Log_Save_File := $(Log_Save_Path)/$(shell date +'%Y-%m-%d_%H-%M-%S').log

# Define how long logs should be kept (in days)
Log_Save_Days = 365


# The main task, first rule, run without arguments
all: remove_old update_ddns
remove_old: remove_old_log remove_old_log_dirs

# Update the DuckDns DDNS with the current IP address and log the activity
update_ddns: domain token if_mac_addr $(Log_Save_Path)
	@echo -n "\tDomain: $(Duck_Domain)\n"
	@echo -n "\tDDNS to: $(IP_ADDR) (by $(IP_INTERFACE))\n"
	@echo -n "\tLog save @ $(Log_Save_File)\n"
	@echo -n '' >> $(Log_Save_File)
	@chmod 600 $(Log_Save_File)  # Minimum required access. 
	@echo -n 'Searching IF with MAC=$(IP_IF_MAC_ADDR)\n' >> $(Log_Save_File)
	@echo -n 'Selected IF=$(IP_INTERFACE)\n' >> $(Log_Save_File)
	@echo -n 'Current IP=$(IP_ADDR)\n' >> $(Log_Save_File)
	@echo -n 'Domain=$(Duck_Domain)\nToken=$(Duck_Token)\n' >> $(Log_Save_File)
	@echo -n 'curl --url=$(Duck_URL)\n\n' >> $(Log_Save_File)
	@echo 'url=$(Duck_URL)' | curl -k -K - >> $(Log_Save_File) 2>&1
	@echo -n '\n\nTask finished.\n' >> $(Log_Save_File)
	@chmod 000 $(Log_Save_File)  # Cut all access. 

# Raise an error if the required files 'domain', 'token' or 'if_mac_addr' do not exist
domain token if_mac_addr:
	$(error Please provide the $@ in '$@' file.)

# Create the log directory if it does not exist
$(Log_Save_Path):
	mkdir -p $(Log_Save_Path)
	chmod go-rwx $(Log_Save_Path) $(dir $(Log_Save_Path))

# Remove old log files that are older than Log_Save_Days
remove_old_log:
	find $(dir $(Log_Save_Path)) -name "*.log" -mtime +$(Log_Save_Days) -exec rm -f {} \;

# Remove old log directories that are older than Log_Save_Days
remove_old_log_dirs:
	find $(dir $(Log_Save_Path)) -type d -mtime +$(Log_Save_Days) -exec rm -rf {} \;

# Define phony targets to avoid conflicts with file names
.PHONY: remove_old remove_old_log remove_old_log_dirs update_ddns all
