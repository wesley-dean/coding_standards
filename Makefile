SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

.PHONY: all clean dist dist-check

all: dist-check

dist:
	bash scripts/build-bundles.bash

dist-check:
	@tmp="$$(mktemp -d)"; \
	trap 'find "$$tmp" -depth -mindepth 1 -delete; rmdir -- "$$tmp"' \
	  EXIT HUP INT TERM; \
	bash scripts/build-bundles.bash >/dev/null; \
	cp dist/coding-standards.tar.gz.sha256 "$$tmp/first.sha256"; \
	bash scripts/build-bundles.bash >/dev/null; \
	cp dist/coding-standards.tar.gz.sha256 "$$tmp/second.sha256"; \
	cmp "$$tmp/first.sha256" "$$tmp/second.sha256"; \
	printf '%s\n' 'standards archive is deterministic'

clean:
	@if [[ -d dist ]]; then \
	  find dist -depth -mindepth 1 -delete; \
	  rmdir -- dist; \
	fi
