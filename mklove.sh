date "+Compiled: %Y/%m/%d %H:%M:%S" > version.txt
rm ./gamex.love
zip -9 -r -x\.git/* ./gamex.love .