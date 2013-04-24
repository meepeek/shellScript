#!/bin/sh

apt-get install -y git aria2 vim
cd /
mkdir data
chown joke data
git clone http://github.com/MeePeek/shellScript
