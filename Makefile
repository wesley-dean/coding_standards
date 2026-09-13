SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

.PHONY: all clean dist dist-check

all: dist-check

dist:
	bash scripts/build-bundles.bash

dist-check:
	@tmp="$$(mktemp -d)"; \
	trap 'rm -rf -- "$$tmp"' EXIT HUP INT TERM; \
	bash scripts/build-bundles.bash >/dev/null; \
	cat dist/*.sha256 >"$$tmp/first.sha256"; \
	bash scripts/build-bundles.bash >/dev/null; \
	cat dist/*.sha256 >"$$tmp/second.sha256"; \
	cmp "$$tmp/first.sha256" "$$tmp/second.sha256"; \
	printf '%s\n' 'standards bundles are deterministic'

clean:
	rm -rf -- dist
