#!/bin/bash
if [ $# -lt 2 ]; then
	echo "usage: $0 <source.xml> <target_folder>"
	exit 0
fi

V_SOURCE_XML=$1
V_SCRIPT_FOLDER=$(cd "$(dirname "$0")"; pwd)
V_TARGET_FOLDER=$2

if [ ! -f ${V_SOURCE_XML} ]; then
	echo "cannot open ${V_SOURCE_XML}";
	exit 0
fi

V_PROJECT_NAME=$(basename ${V_SOURCE_XML} | sed 's/\.xml$//g')

if [ -d ${V_TARGET_FOLDER}/${V_PROJECT_NAME} ]; then
	echo -n "${V_TARGET_FOLDER}/${V_PROJECT_NAME} already exists, replace it?(Y/N)"
	read V_YESNO
	if [ "${V_YESNO}" != "Y" ] && [ "${V_YESNO}" != "y" ]; then
		exit 0;
	fi
fi

mkdir -p ${V_TARGET_FOLDER}/${V_PROJECT_NAME}
mkdir -p ${V_TARGET_FOLDER}/${V_PROJECT_NAME}/lib

php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} client/ios/structs_header_builder.tpl > ${V_TARGET_FOLDER}/${V_PROJECT_NAME}/lib/webc_structs.h
php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} client/ios/structs_source_builder.tpl > ${V_TARGET_FOLDER}/${V_PROJECT_NAME}/lib/webc_structs.m
php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} client/ios/interfaces_header_builder.tpl > ${V_TARGET_FOLDER}/${V_PROJECT_NAME}/lib/webc_interfaces.h
php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} client/ios/interfaces_source_builder.tpl > ${V_TARGET_FOLDER}/${V_PROJECT_NAME}/lib/webc_interfaces.m
echo "building done";
