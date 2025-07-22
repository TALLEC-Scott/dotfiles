curl -LsSf https://astral.sh/uv/install.sh | sh
source $HOME/.local/bin/env #refresh

# list of tools, should perhaps create a seperate file for this
tools=(
  ruff@latest
  nvitop
  speedtest-cli
  gpustat
  cowsay #integral to my setup
  
)

# Install each one in turn
for t in "${tools[@]}"; do
  uv tool install "$t"
done

uv python install 3.12 --default --preview


curl -s https://ohmyposh.dev/install.sh | bash -s
# add font install aswell


curl -fLo ~/.vim/autoload/plug.vim --create-dirs \
    https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim
sudo apt install build-essential cmake vim-nox python3-dev 
sudo apt install mono-complete golang nodejs default-jdk npm
sudo apt install -y bat
cd ~/.vim/bundle/YouCompleteMe
python3 install.py --all

# the executable is called batcat due to a naming conflict
ln -s /usr/bin/batcat ~/.local/bin/bat


git config --global core.editor vim
