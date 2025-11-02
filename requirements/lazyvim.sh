#!/bin/bash
# Installation: https://www.lazyvim.org/installation

mkdir -p /etc/skel/.config
git clone --filter=blob:none https://github.com/LazyVim/starter /etc/skel/.config/nvim
rm -rf /etc/skel/.config/nvim/.git

echo "LazyVim installed to /etc/skel/.config/nvim"
echo "This will be automatically copied to ~/.config/nvim for all new users"