.PHONY: help build check

help: ## Show available targets
	@grep -E '^[a-z]+:.*## ' $(MAKEFILE_LIST) | awk -F':.*## ' '{printf "  make %-6s %s\n", $$1, $$2}'

build: ## Regenerate shared sections and rk-full-review
	python3 scripts/build.py

check: ## Fail if any generated file is out of date (what CI runs)
	python3 scripts/build.py --check
