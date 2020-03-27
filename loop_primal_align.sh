#!/bin/bash

#IFS=$'\n'

for i in $(find . -mindepth 1 -maxdepth 1 -type d)
do
	sName=$(echo $i | sed 's/^.\///')
        echo "Moving into folder $sName"

	cd $sName

	/home4/nCov/Richard/Ref/primal_align.sh
	
	cd ../
done

