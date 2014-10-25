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

mkdir -p ${V_TARGET_FOLDER}/

php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} ${V_SCRIPT_FOLDER}/client/php/structs_builder.tpl > ${V_TARGET_FOLDER}/structs.class.php
php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} ${V_SCRIPT_FOLDER}/client/php/errors_builder.tpl > ${V_TARGET_FOLDER}/errors.class.php
php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} ${V_SCRIPT_FOLDER}/client/php/interfaces_builder.tpl > ${V_TARGET_FOLDER}/interfaces.class.php
echo "building done";
