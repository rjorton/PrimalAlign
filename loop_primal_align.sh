#!/bin/bash

#IFS=$'\n'

primerV=${1}

if [[ -z ${primerV} ]];
then
	primerV=V1
	echo "No primers defined so using V1 primers by default: ${primerV}"
elif [[ ${1} == "V1" || ${1} == "v1" || ${1} == "1" ]];
then
        primerV=V1
        echo "Using V1 primers: ${primerV}"
elif [[ ${1} == "V2" || ${1} == "v2" || ${1} == "2" ]];
then
        primerV=V2
        echo "Using V2 primers: ${primerV}"
elif [[ ${1} == "V3" || ${1} == "v3" || ${1} == "3" ]];
then
        primerV=V3
        echo "Using V3 primers: ${primerV}"
else
	echo "Unrecognised primers: ${1}"
	echo "Exiting"
	exit 1
fi

for i in $(find . -mindepth 1 -maxdepth 1 -type d)
do
	sName=$(echo $i | sed 's/^.\///')
        echo "Moving into folder $sName"

	cd $sName

	/home4/nCov/Richard/Ref/primal_align.sh ${primerV}
	
	cd ../
done

