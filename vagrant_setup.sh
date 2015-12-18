#!/bin/bash

_update=0 

# Update time to aus/sydney
sudo timedatectl set-timezone 'Australia/Sydney'

# Updates
if [ "_update" =  true ]; then
sudo apt-get -y update
sudo apt-get -y upgrade

sudo apt-get -y install git
sudo apt-get -y install python3-pip
sudo apt-get -y install screen
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
sudo tee /etc/apt/sources.list.d/emdebian.list << EOF
deb http://mirrors.mit.edu/debian squeeze main
deb http://www.emdebian.org/debian squeeze main
EOF
sudo apt-get -y install libc6-mipsel-cross
sudo apt-get -y install libc6-arm-cross
sudo apt-get -y install libc6-dev-i386 
fi

if [ ! -d "/etc/qemu-binfmt" ]; then
  sudo mkdir /etc/qemu-binfmt;
  sudo ln -s /usr/mipsel-linux-gnu /etc/qemu-binfmt/mipsel;
  sudo ln -s /usr/arm-linux-gnueabihf /etc/qemu-binfmt/arm;
  sudo rm /etc/apt/sources.list.d/emdebian.list;
fi

# Install Binjitsu
# because fuck it
if ! pip show binjitsu > /dev/null 2>&1 ; then
  sudo apt-get -y install python2.7 python-pip python-dev git
  sudo pip install git+https://github.com/binjitsu/binjitsu.git
fi

cd
mkdir tools
cd tools

# Install pwndbg
if [ ! -d "$HOME/tools/pwndbg" ]; then
  git clone https://github.com/zachriggle/pwndbg
  echo source `pwd`/pwndbg/gdbinit.py >> ~/.gdbinit
fi

# Capstone for pwndbg
if [ ! -d "$HOME/tools/capstone" ]; then
  git clone https://github.com/aquynh/capstone
  cd capstone
  git checkout -t origin/next
  sudo ./make.sh install
  cd bindings/python
  sudo python3 setup.py install # Ubuntu 14.04+, GDB uses Python3
fi

# pycparser for pwndbg
if ! pip3 show pycparser > /dev/null 2>&1 ; then
  sudo pip3 install pycparser # Use pip3 for Python3
fi

# Install radare2
if [ ! -d "/usr/share/radare2" ]; then
  git clone https://github.com/radare/radare2
  cd radare2
  ./sys/install.sh
fi

# Install binwalk
cd $HOME/tools 
if [ ! -d "$HOME/tools/binwalk" ]; then
  git clone https://github.com/devttys0/binwalk
  cd binwalk
  sudo python setup.py install
fi

# Install Firmware-Mod-Kit
if [ ! -d "$HOME/tools/fmk" ]; then
  sudo apt-get -y build-essential zlib1g-dev liblzma-dev python-magic
  cd $HOME/tools
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

# Install zsh
sudo apt-get -y install zsh

# Install oh-my-zsh
sh -c "$(curl -fsSL https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"

# Personal config
sudo sudo apt-get -y install stow
cd /home/vagrant
rm .bashrc
rm .zshrc
rm -rf .oh-my-zsh
rm -rf .vim
git clone https://github.com/CarlNeuhaus/dotfiles
cd dotfiles
./install.sh

# Install vim plugins
# Probably not needed anymore because .vim is synced
#vim +PluginInstall +qall

# Install Angr
cd $HOME/tools
if [ ! -d "$HOME/tools/angr" ]; then
  sudo apt-get -y install python-dev libffi-dev build-essential virtualenvwrapper
  sudo pip install virtualenv
  virtualenv angr
  source angr/bin/activate
  pip install angr --upgrade
fi

# Install ropgadget
if [ ! -d "$HOME/tools/ROPgadget" ]; then
  cd ~/tools
  git clone https://github.com/JonathanSalwan/ROPgadget
  cd ROPgadget
  sudo python setup.py install
fi

# ctf-tools installers
cd $HOME/tools
if [ ! -d "$HOME/tools/installers" ]; then
  mkdir installers
  cd installers
  git clone https://github.com/CarlNeuhaus/ctf-tools
fi

# preeny - bunch of preload libraries to pwn shit
cd $HOME/tools
if [ ! -d "$HOME/tools/preeny" ]; then
  git clone https://github.com/CarlNeuhaus/preeny
fi
