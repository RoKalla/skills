.PHONY: help build check version

help: ## Show available targets
	@grep -E '^[a-z]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-8s %s\n", $$1, $$2}'

build: ## Regenerate shared sections and rk-full-review
	python3 scripts/build.py

check: ## Fail if generated files are out of date or versions differ (what CI runs)
	python3 scripts/build.py --check

version: ## Set the version everywhere, then build: make version V=1.2.0
	@test -n "$(V)" || { echo "usage: make version V=1.2.0"; exit 1; }
	python3 scripts/build.py --set-version $(V)
