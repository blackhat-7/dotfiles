.PHONY: run

run:
	sudo darwin-rebuild switch --flake .#illusion

update:
	sudo nix flake update

index:
	nix run 'nixpkgs#nix-index' --extra-experimental-features 'nix-command flakes'

repair:
	sudo nix-store --verify --check-contents --repair


