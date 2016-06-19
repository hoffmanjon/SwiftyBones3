#!/bin/sh

FILELIST=""
OUTPUTFILE=""

if [ $# -gt 0 ]
then
	OUTPUTFILE="-o $1"
fi

for f in $(find ./ -name '*.swift')
do 
	
	FILELIST="$FILELIST $f"
done

echo $FILELIST

swiftc $OUTPUTFILE $FILELIST

