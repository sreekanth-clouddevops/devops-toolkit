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
	@find bin scripts tests -type f -name "*.sh" -print0 | xargs -0 -r shellcheck -S error

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

.PHONY: docker-build docker-run docker-clean docker-size

IMAGE ?= sree/devops-toolkit
TAG ?= v2

docker-build:
	@docker build -t $(IMAGE):$(TAG) .

docker-run:
	@docker run --rm -it $(IMAGE):$(TAG) /bin/bash -lc "system_check || true; ls /app"

docker-clean:
	@docker image prune -f

docker-size:
	@docker image inspect $(IMAGE):$(TAG) --format='{{.Size}}' 2>/dev/null | awk '{print int($$1/1024/1024) " MB"}' || echo "image not found"

.PHONY: docker-pull docker-smoke docker-rm

docker-pull:
	@docker pull $(IMAGE):$(TAG)

# Run a tiny smoke test in a clean container and assert expected output
docker-smoke:
	@echo "[smoke] running container $(IMAGE):$(TAG)…"
	@docker run --rm $(IMAGE):$(TAG) /bin/bash -lc '\
		set -euo pipefail; \
		/app/bin/system_check > /tmp/sys.log 2>&1 || true; \
		grep -qi "===== System Check Start =====" /tmp/sys.log \
		&& echo "[smoke] system_check ok" \
		|| { echo "[smoke] system_check missing expected banner"; cat /tmp/sys.log; exit 1; } \
	'
	@echo "[smoke] OK"

docker-rm:
	@docker ps -aq --filter "ancestor=$(IMAGE):$(TAG)" | xargs -r docker rm -f
