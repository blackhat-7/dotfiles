USER=$(whoami)
HOME=/home/$USER
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

# tmux
cp ~/.files/.config/tmux/.tmux.conf ~/.tmux.conf
git clone https://github.com/tmux-plugins/tpm ~/.tmux/plugins/tpm

# atuin
bash <(curl https://raw.githubusercontent.com/atuinsh/atuin/main/install.sh)
atuin import auto

# zoxide
sudo apt install zoxide
# add this to the end of ~/.config/fish/config.fish: zoxide init fish | source
echo 'zoxide init fish | source' >> ~/.config/fish/config.fish
echo 'alias cd=z' >> ~/.config/fish/config.fish

# conda
mkdir -p ~/miniconda3
wget https://repo.anaconda.com/miniconda/Miniconda3-latest-Linux-x86_64.sh -O ~/miniconda3/miniconda.sh
bash ~/miniconda3/miniconda.sh -b -u -p ~/miniconda3
rm -rf ~/miniconda3/miniconda.sh
~/miniconda3/bin/conda init fish

# go
cd ~/Downloads || exit
curl -LO https://go.dev/dl/go1.22.4.linux-amd64.tar.gz 
sudo rm -rf /usr/local/go && sudo tar -C /usr/local -xzf go1.22.4.linux-amd64.tar.gz
fish_add_path /usr/local/go/bin

# rust
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh



# Done
cd ~/ || exit
