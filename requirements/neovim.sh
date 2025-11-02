#!/bin/bash
# Install neovim

wget https://github.com/neovim/neovim/releases/download/v0.11.4/nvim-linux-x86_64.tar.gz

tar -xzf nvim-linux-x86_64.tar.gz
cp -r nvim-linux-x86_64/* /usr/local/
rm -rf nvim-linux-x86_64*

echo "Neovim installed successfully"
nvim --version