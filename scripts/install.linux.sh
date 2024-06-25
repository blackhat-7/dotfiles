USER=$(whoami)
echo "Installing basic config for user $USER"

# Dirs
cd ~/ || exit
mkdir -p Documents/clones
mkdir -p Downloads

# Dependencies
sudo apt update && sudo apt upgrade
sudo apt install zip git

# fish
sudo apt-add-repository ppa:fish-shell/release-3
sudo apt update
sudo apt install fish
chsh -s /usr/bin/fish
fish

# Switch to Fish shell and run the second script
exec fish -c 'source ./install2.linux.fish'
