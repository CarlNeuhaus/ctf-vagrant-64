#!/bin/bash

# Updates
sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get -y install python3-pip
sudo apt-get -y install tmux
sudo apt-get -y install gdb gdb-multiarch
sudo apt-get -y install unzip
sudo apt-get -y install foremost

# QEMU with MIPS/ARM - http://reverseengineering.stackexchange.com/questions/8829/cross-debugging-for-mips-elf-with-qemu-toolchain
sudo apt-get -y install qemu qemu-user qemu-user-static
sudo apt-get -y install 'binfmt*'
sudo apt-get -y install libc6-armhf-armel-cross
sudo apt-get -y install debian-keyring
sudo apt-get -y install debian-archive-keyring
sudo apt-get -y install emdebian-archive-keyring
tee /etc/apt/sources.list.d/emdebian.list << EOF
deb http://mirrors.mit.edu/debian squeeze main
deb http://www.emdebian.org/debian squeeze main
EOF
sudo apt-get -y install libc6-mipsel-cross
sudo apt-get -y install libc6-arm-cross

if [ ! -d "/etc/qemu-binfmt" ]; then
  mkdir /etc/qemu-binfmt
  ln -s /usr/mipsel-linux-gnu /etc/qemu-binfmt/mipsel 
  ln -s /usr/arm-linux-gnueabihf /etc/qemu-binfmt/arm
  rm /etc/apt/sources.list.d/emdebian.list
fi
# sudo apt-get update

# Install Binjitsu
sudo apt-get -y install python2.7 python-pip python-dev git
sudo pip install --upgrade git+https://github.com/binjitsu/binjitsu.git

cd
mkdir tools
cd tools

# Install pwndbg
git clone https://github.com/zachriggle/pwndbg
echo source `pwd`/pwndbg/gdbinit.py >> ~/.gdbinit

# Capstone for pwndbg
if [ ! -d "~/tools/capstone" ]; then
  git clone https://github.com/aquynh/capstone
  cd capstone
  git checkout -t origin/next
  sudo ./make.sh install
  cd bindings/python
  sudo python3 setup.py install # Ubuntu 14.04+, GDB uses Python3
fi

# pycparser for pwndbg
sudo pip3 install pycparser # Use pip3 for Python3

# Install radare2
if [ ! -d "/usr/share/radare2" ]; then
  git clone https://github.com/radare/radare2
  cd radare2
  ./sys/install.sh
fi

# Install binwalk
cd 
if [ ! -d "~/binwalk" ]; then
  git clone https://github.com/devttys0/binwalk
  cd binwalk
  sudo python setup.py install
fi

# Install Firmware-Mod-Kit
sudo apt-get -y install git build-essential zlib1g-dev liblzma-dev python-magic
if [ ! -d "~/tools/fmk" ]; then
  cd ~/tools
  wget https://firmware-mod-kit.googlecode.com/files/fmk_099.tar.gz
  tar xvf fmk_099.tar.gz
  rm fmk_099.tar.gz
  cd fmk_099/src
  ./configure
  make
fi

# Uninstall capstone
sudo pip2 uninstall capstone -y

# Install correct capstone
cd ~/tools/capstone/bindings/python
sudo python setup.py install

# Personal config
sudo sudo apt-get -y install stow
cd /home/vagrant
rm .bashrc
git clone https://github.com/thebarbershopper/dotfiles
cd dotfiles
./install.sh

# Install Angr
cd /home/vagrant
sudo apt-get -y install python-dev libffi-dev build-essential virtualenvwrapper
sudo pip install virtualenv
virtualenv angr
source angr/bin/activate
pip install angr --upgrade

# Install ropgadget
if [ ! -d "~/tools/ROPgadget" ]; then
  cd ~/tools
  git clone https://github.com/JonathanSalwan/ROPgadget
  cd ROPgadget
  sudo python setup.py install
fi

# Install zsh
sudo apt-get -y install zsh

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Install z.sh
cd ~
wget https://raw.githubusercontent.com/rupa/z/master/z.sh -O .z.sh

# Update .zshrc
# TODO this will be handled by stow
cd
wget https://raw.githubusercontent.com/CarlNeuhaus/config_files/master/zsh/zshrc -O .zshrc

# Install vundle into vim
git clone https://github.com/VundleVim/Vundle.vim.git ~/.vim/bundle/Vundle.vim
vim +PluginInstall +qall

# Update .vimrc
# TODO this will be handled by stow
cd ~
wget https://raw.githubusercontent.com/CarlNeuhaus/config_files/master/vim/vimrc -O .vimrc

# Update time to aus/sydney
sudo timedatectl set-timezone 'Australia/Sydney'

# Install libc6-dev-i386 for cross compiling -m32
sudo apt-get -y install libc6-dev-i386
