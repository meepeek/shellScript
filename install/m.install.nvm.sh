#!/bin/sh

wget -qO- https://raw.githubusercontent.com/creationix/nvm/v0.24.0/install.sh | sh

echo "export NVM_DIR=~/.nvm\nsource ~/.nvm/nvm.sh" >> .zshrc
echo "export NVM_DIR=~/.nvm\nsource ~/.nvm/nvm.sh" >> .bashrc

export NVM_DIR=~/.nvm
source $NVM_DIR/nvm.sh

nvm install iojs
