# !/bin/sh
#if echo "$1" | grep -q "[upgrade]" || echo "$2" | grep -q "[install]" || echo "$2" | grep -q "dist-upgrade"; then 
  echo "Joke's apt multi-process cache download accelerating script."
  echo "Processing ... ";
  cd /var/cache/apt/archives/;
  sudo apt-get -y --print-uris install $1 > /home/joke/debs.list
  sudo egrep -o -e "(ht|f)tp://[^\']+" /home/joke/debs.list > /home/joke/download.list;
  while read line ; do
#    axel -a $line &
    sudo aria2c $line &
    sleep 1;
  done < /home/joke/download.list
#else
#  echo "Invalid parameter."
#fi
