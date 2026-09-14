SHELL := /bin/bash
.SHELLFLAGS := -eu -o pipefail -c

DIST_DIR := dist
ARCHIVE := $(DIST_DIR)/coding_standards.tar.gz
CHECKSUM := $(ARCHIVE).sha256

.PHONY: all clean dist-check

all: clean
	@command -v tar >/dev/null 2>&1 || { printf '%s\n' 'GNU tar is required' >&2; exit 1; }
	@tar --version | grep -q 'GNU tar' || { printf '%s\n' 'GNU tar is required' >&2; exit 1; }
	@command -v gzip >/dev/null 2>&1 || { printf '%s\n' 'gzip is required' >&2; exit 1; }
	@test -d standards || { printf '%s\n' 'standards directory not found' >&2; exit 1; }
	@first_link="$$(find standards -type l -print -quit)"; \
	if [[ -n "$$first_link" ]]; then \
	  printf 'symbolic links are not permitted in standards: %s\n' "$$first_link" >&2; \
	  exit 1; \
	fi
	@mkdir -p "$(DIST_DIR)"
	@tmp="$$(mktemp -d "$${TMPDIR:-/tmp}/coding_standards.XXXXXX")"; \
	archive_tmp="$(ARCHIVE).tmp"; \
	checksum_tmp="$(CHECKSUM).tmp"; \
	cleanup() { \
	  rm -f -- "$$archive_tmp" "$$checksum_tmp"; \
	  if [[ -d "$$tmp" ]]; then \
	    find "$$tmp" -depth -mindepth 1 -delete; \
	    rmdir -- "$$tmp"; \
	  fi; \
	}; \
	trap cleanup EXIT HUP INT TERM; \
	cp -R -- standards/. "$$tmp/"; \
	find "$$tmp" -type d -exec chmod 0755 {} +; \
	find "$$tmp" -type f -exec chmod 0644 {} +; \
	tar \
	  --sort=name \
	  --mtime='UTC 1970-01-01' \
	  --owner=0 \
	  --group=0 \
	  --numeric-owner \
	  -cf - \
	  -C "$$tmp" . | gzip -n >"$$archive_tmp"; \
	mv -- "$$archive_tmp" "$(ARCHIVE)"; \
	if command -v sha256sum >/dev/null 2>&1; then \
	  digest="$$(sha256sum -- "$(ARCHIVE)" | awk '{print $$1}')"; \
	elif command -v shasum >/dev/null 2>&1; then \
	  digest="$$(shasum -a 256 -- "$(ARCHIVE)" | awk '{print $$1}')"; \
	else \
	  printf '%s\n' 'sha256sum or shasum -a 256 is required' >&2; \
	  exit 1; \
	fi; \
	printf '%s  %s\n' "$$digest" 'coding_standards.tar.gz' >"$$checksum_tmp"; \
	mv -- "$$checksum_tmp" "$(CHECKSUM)"; \
	cleanup; \
	trap - EXIT HUP INT TERM

dist-check:
	@tmp="$$(mktemp -d "$${TMPDIR:-/tmp}/coding_standards-check.XXXXXX")"; \
	trap 'find "$$tmp" -depth -mindepth 1 -delete; rmdir -- "$$tmp"' EXIT HUP INT TERM; \
	$(MAKE) --no-print-directory all >/dev/null; \
	cp "$(ARCHIVE)" "$$tmp/first.tar.gz"; \
	cp "$(CHECKSUM)" "$$tmp/first.sha256"; \
	$(MAKE) --no-print-directory all >/dev/null; \
	cmp "$$tmp/first.tar.gz" "$(ARCHIVE)"; \
	cmp "$$tmp/first.sha256" "$(CHECKSUM)"; \
	printf '%s\n' 'standards archive is deterministic'

clean:
	@if [[ -d "$(DIST_DIR)" ]]; then \
	  find "$(DIST_DIR)" -depth -mindepth 1 -delete; \
	  rmdir -- "$(DIST_DIR)"; \
	fi
