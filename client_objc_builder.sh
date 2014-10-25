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

mkdir -p ${V_TARGET_FOLDER}

php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} ${V_SCRIPT_FOLDER}/client/objc/structs_header_builder.tpl > ${V_TARGET_FOLDER}/WebcStructs.h
php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} ${V_SCRIPT_FOLDER}/client/objc/structs_source_builder.tpl > ${V_TARGET_FOLDER}/WebcStructs.m
php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} ${V_SCRIPT_FOLDER}/client/objc/errors_header_builder.tpl > ${V_TARGET_FOLDER}/WebcErrors.h
php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} ${V_SCRIPT_FOLDER}/client/objc/errors_source_builder.tpl > ${V_TARGET_FOLDER}/WebcErrors.m
php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} ${V_SCRIPT_FOLDER}/client/objc/interfaces_header_builder.tpl > ${V_TARGET_FOLDER}/WebcInterfaces.h
php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} ${V_SCRIPT_FOLDER}/client/objc/interfaces_source_builder.tpl > ${V_TARGET_FOLDER}/WebcInterfaces.m
echo "building done";