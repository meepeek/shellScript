# ! /bin/sh
for ((i=0 ; i<=60 ; i++))
do
	wget "http://www.ourmanga.com/manga/Aki-Sora/Chapter-2/$(printf "%03d" ${i%}).png" &
done
