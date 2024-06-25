USER=$(whoami)
HOME="/home/$USER"
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

# Switch to Fish shell and run the second script
SCRIPT_PATH="$HOME/.files/scripts/install2.linux.fish"
if [[ ! -f "$SCRIPT_PATH" ]]; then
    echo "Error: $SCRIPT_PATH does not exist."
    exit 1
fi

# Switch to Fish shell and run the second script
exec fish -c "source $SCRIPT_PATH"
