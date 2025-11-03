SHELL := /usr/bin/env bash
REPO_ROOT := $(shell git rev-parse --show-toplevel)
DIST := dist
VERSION ?= $(shell git describe --tags --always --dirty 2>/dev/null || echo v0.0.0)

.PHONY: help lint test package clean install uninstall

help:
	@echo "Targets:"
	@echo "  lint      - run shellcheck on scripts"
	@echo "  test      - run tests"
	@echo "  package   - create tarball under dist/ with $(VERSION)"
	@echo "  install   - symlink commands to ~/bin"
	@echo "  uninstall - remove symlinks from ~/bin"
	@echo "  clean     - remove dist/ and temp files"

lint:
	@echo "[lint] shellcheck…"
	@find bin scripts tests -type f -name "*.sh" -print0 | xargs -0 -r shellcheck

test:
	@echo "[test] running tests…"
	@./tests/run_tests.sh

package: clean
	@echo "[package] creating tarball for $(VERSION)…"
	@mkdir -p $(DIST)
	@tar -czf $(DIST)/devops-toolkit_$(VERSION).tar.gz \
		--exclude=.git --exclude=$(DIST) --owner=0 --group=0 .

install:
	@mkdir -p $$HOME/bin
	@ln -sf $(REPO_ROOT)/bin/system_check.sh $$HOME/bin/system_check
	@ln -sf $(REPO_ROOT)/bin/disk_alert.sh  $$HOME/bin/disk_alert
	@ln -sf $(REPO_ROOT)/bin/menu.sh        $$HOME/bin/devops-menu
	@echo "Added to $$HOME/bin (ensure it's in PATH)"

uninstall:
	@rm -f $$HOME/bin/system_check $$HOME/bin/disk_alert $$HOME/bin/devops-menu
	@echo "Removed symlinks from $$HOME/bin"

clean:
	@rm -rf $(DIST)
