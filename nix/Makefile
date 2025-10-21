# Define paths to Nix executables
NIX_BIN := /nix/var/nix/profiles/default/bin
NIX := $(NIX_BIN)/nix
NIX_STORE := $(NIX_BIN)/nix-store

.PHONY: switch darwin linux update repair index rollback darwin-rollback linux-rollback

# Default target
switch:
	@if [ "$$(uname)" = "Darwin" ]; then \
		echo "Detected macOS, applying configuration..."; \
		$(MAKE) darwin; \
	else \
		echo "Detected Linux, applying configuration..."; \
		$(MAKE) linux; \
	fi

# macOS-specific target
darwin:
	sudo darwin-rebuild switch --flake .#illusion

# Linux-specific target
linux:
	sudo $(NIX) run github:numtide/system-manager -- switch --flake .

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
