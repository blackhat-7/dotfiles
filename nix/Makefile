# Define paths to Nix executables
NIX_BIN := /nix/var/nix/profiles/default/bin
NIX := $(NIX_BIN)/nix
NIX_STORE := $(NIX_BIN)/nix-store

.PHONY: switch darwin linux home update repair index rollback darwin-rollback linux-rollback

# Default target
switch:
	@if [ "$$(uname)" = "Darwin" ]; then \
		echo "Detected macOS, applying configuration..."; \
		$(MAKE) darwin; \
	else \
		echo "Detected Linux, applying configuration..."; \
		$(MAKE) linux; \
	fi
	$(MAKE) home

# macOS-specific target
darwin:
	sudo darwin-rebuild switch --flake .#illusion

# Linux-specific target
linux:
	@if [ "$$(uname -m)" = "aarch64" ]; then \
		echo "Detected ARM64 architecture, using aarch64 configuration..."; \
		sudo $(NIX) run github:numtide/system-manager -- switch --flake .#illusion-aarch64; \
	else \
		echo "Detected x86_64 architecture, using default configuration..."; \
		sudo $(NIX) run github:numtide/system-manager -- switch --flake .#illusion; \
	fi

# Home Manager target for Linux
home:
	@if [ "$$(uname -m)" = "aarch64" ]; then \
		echo "Detected ARM64 architecture, using aarch64 home configuration..."; \
		PATH="$(NIX_BIN):$$PATH" $(NIX) run home-manager/master -- switch --flake .#illusion-aarch64 -b hm-backup-$(shell date +%Y%m%d%H%M%S); \
	else \
		echo "Detected x86_64 architecture, using default home configuration..."; \
		PATH="$(NIX_BIN):$$PATH" $(NIX) run home-manager/master -- switch --flake .#illusion -b hm-backup-$(shell date +%Y%m%d%H%M%S); \
	fi

# Update flake inputs
update:
	$(NIX) flake update

# Run nix-index
index:
	$(NIX) run 'nixpkgs#nix-index'

# Repair nix store
repair:
	sudo $(NIX_STORE) --verify --check-contents --repair

# Rollback to previous configuration
rollback:
	@if [ "$$(uname)" = "Darwin" ]; then \
		echo "Rolling back macOS configuration..."; \
		$(MAKE) darwin-rollback; \
	else \
		echo "Rolling back Linux configuration..."; \
		$(MAKE) linux-rollback; \
	fi

# macOS rollback
darwin-rollback:
	sudo darwin-rebuild switch --flake .#illusion --rollback

# Linux rollback
linux-rollback:
	sudo $(NIX) run github:numtide/system-manager -- rollback
