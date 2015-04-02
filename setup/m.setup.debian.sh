cd
wget https://raw.github.com/robbyrussell/oh-my-zsh/master/tools/install.sh -O - | sh

apt-get -y install aria2 axel git zsh

cd /
mkdir data
cd data/
mkdir shellScript
cd shellScript/
git clone https://github.com/meepeek/shellScript . &

cd /data/user
mkdir user
cd user/
mkdir template
cd template/
scp -P5556 thee@secret.meepeek.com:.zshrc .
