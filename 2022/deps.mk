LOCAL_BIN := $(CURDIR)/bin
$(LOCAL_BIN):
	mkdir -p $@

PATH := $(LOCAL_BIN):$(PATH)
export PATH

.PHONY: env
env::
	@echo 'alias m=make'
	@echo 'export PATH="$(LOCAL_BIN):$$PATH"'

ifeq ($(PLATFORM),Darwin)
OPEN := open
else
OPEN := xdg-open
endif

XDG_CONFIG_HOME := $(CURDIR)/.config
export XDG_CONFIG_HOME
env::
	@echo 'export XDG_CONFIG_HOME="$(XDG_CONFIG_HOME)"'


CURL ?= /usr/bin/curl
ifeq ($(PLATFORM),Linux)
$(CURL):
	@sudo apt-get update && sudo apt-get install curl
endif

K9S_RELEASES := https://github.com/derailed/k9s/releases
K9S_VERSION := 0.24.15
K9S_BIN_DIR := $(LOCAL_BIN)/k9s-$(K9S_VERSION)-$(platform)-x86_64
K9S_URL := $(K9S_RELEASES)/download/v$(K9S_VERSION)/k9s_$(platform)_x86_64.tar.gz
K9S := $(K9S_BIN_DIR)/k9s
$(K9S): | $(CURL) $(LOCAL_BIN)
	$(CURL) --progress-bar --fail --location --output $(K9S_BIN_DIR).tar.gz "$(K9S_URL)"
	mkdir -p $(K9S_BIN_DIR) && tar zxf $(K9S_BIN_DIR).tar.gz -C $(K9S_BIN_DIR)
	touch $(K9S)
	chmod +x $(K9S)
	$(K9S) version | grep $(K9S_VERSION)
	ln -sf $(K9S) $(LOCAL_BIN)/k9s

.PHONY: releases-k9s
releases-k9s:
	$(OPEN) $(K9S_RELEASES)

JQ_RELEASES := https://github.com/stedolan/jq/releases
JQ_VERSION := 1.6
JQ_BIN := jq-$(JQ_VERSION)-$(platform)-x86_64
JQ_URL := $(JQ_RELEASES)/download/jq-$(JQ_VERSION)/jq-$(platform)64
ifeq ($(platform),darwin)
JQ_URL := $(JQ_RELEASES)/download/jq-$(JQ_VERSION)/jq-osx-amd64
endif
JQ := $(LOCAL_BIN)/$(JQ_BIN)
$(JQ): | $(CURL) $(LOCAL_BIN)
	$(CURL) --progress-bar --fail --location --output $(JQ) "$(JQ_URL)"
	touch $(JQ)
	chmod +x $(JQ)
	$(JQ) --version | grep $(JQ_VERSION)
	ln -sf $(JQ) $(LOCAL_BIN)/jq
.PHONY: jq
jq: $(JQ)
.PHONY: releases-jq
releases-jq:
	$(OPEN) $(JQ_RELEASES)

ifeq ($(PLATFORM),Darwin)
LPASS := /usr/local/bin/lpass
$(LPASS):
	@brew install lastpass-cli $(SILENT)
endif
ifeq ($(PLATFORM),Linux)
LPASS := /usr/bin/lpass
$(LPASS):
	@sudo apt-get update && sudo apt-get install lastpass-cli
endif

# lastpass-cli requires this directory to exist for it to work properly
env::
	@mkdir -p $(XDG_CONFIG_HOME)/lpass

HELM_RELEASES := https://github.com/helm/helm/releases
HELM_VERSION := 3.7.1
HELM_BIN_DIR := helm-v$(HELM_VERSION)-$(platform)-amd64
HELM_URL := https://get.helm.sh/$(HELM_BIN_DIR).tar.gz
HELM := $(LOCAL_BIN)/$(HELM_BIN_DIR)/$(platform)-amd64/helm
$(HELM): | $(CURL) $(LOCAL_BIN)
	$(CURL) --progress-bar --fail --location --output $(LOCAL_BIN)/$(HELM_BIN_DIR).tar.gz "$(HELM_URL)"
	mkdir -p $(LOCAL_BIN)/$(HELM_BIN_DIR) && tar zxf $(LOCAL_BIN)/$(HELM_BIN_DIR).tar.gz -C $(LOCAL_BIN)/$(HELM_BIN_DIR)
	touch $(HELM)
	chmod +x $(HELM)
	$(HELM) version | grep $(HELM_VERSION)
	ln -sf $(HELM) $(LOCAL_BIN)/helm
.PHONY: helm
helm: $(HELM)


.PHONY: releases-helm
releases-helm:
	$(OPEN) $(HELM_RELEASES)

# We want to fail if variables are not set or empty.
# The envsubst that comes with gettext does not support this,
# using this Go version instead: https://github.com/a8m/envsubst#docs
ENVSUBST_RELEASES := https://github.com/a8m/envsubst/releases
ENVSUBST_VERSION := 1.2.0
ENVSUBST_BIN := envsubst-$(ENVSUBST_VERSION)-$(PLATFORM)-x86_64
ENVSUBST_URL := $(ENVSUBST_RELEASES)/download/v$(ENVSUBST_VERSION)/envsubst-$(PLATFORM)-x86_64
ENVSUBST := $(LOCAL_BIN)/$(ENVSUBST_BIN)
ENVSUBST_SAFE := $(ENVSUBST) -no-unset -no-empty
$(ENVSUBST): | $(CURL) $(LOCAL_BIN)
	$(CURL) --progress-bar --fail --location --output $(ENVSUBST) "$(ENVSUBST_URL)"
	touch $(ENVSUBST)
	chmod +x $(ENVSUBST)
	ln -sf $(ENVSUBST) $(LOCAL_BIN)/envsubst
.PHONY: envsubst
envsubst: $(ENVSUBST)
.PHONY: releases-envsubst
releases-envsubst:
	$(OPEN) $(ENVSUBST_RELEASES)
