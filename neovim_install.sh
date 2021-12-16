#!/bin/bash

##epelリポジトリのインストール
sudo yum -y install libtool autoconf automake cmake gcc gcc-c++ make pkgconfig unzip

git clone https://github.com/neovim/neovim

cd neovim

make

sudo make install

mkdir ~/.config

cd ~/.config

mkdir nvim

sh -c 'curl -fLo "${XDG_DATA_HOME:-$HOME/.local/share}"/nvim/site/autoload/plug.vim --create-dirs \
       https://raw.githubusercontent.com/junegunn/vim-plug/master/plug.vim'

git clone https://github.com/w0ng/vim-hybrid.git

mv vim-hybrid/colors/ nvim

sudo yum -y install nodejs
npm install -g yarn
