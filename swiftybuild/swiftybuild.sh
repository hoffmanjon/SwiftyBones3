#!/bin/sh
#title				:swiftybuild.sh
#author				:Jon Hoffman
#description	:This script will search the currect directory and all subdirectories for files with the .swift extension.  It will then compile all of those files and build an application with
#usage				:./swiftybuild.sh  or  ./swiftybuild.sh {output file name}

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

