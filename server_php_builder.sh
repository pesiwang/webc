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
mkdir -p ${V_TARGET_FOLDER}/lib/webc/
mkdir -p ${V_TARGET_FOLDER}/app

php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} ${V_SCRIPT_FOLDER}/server/php/structs_builder.tpl > ${V_TARGET_FOLDER}/lib/webc/structs.class.php
php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} ${V_SCRIPT_FOLDER}/server/php/errors_builder.tpl > ${V_TARGET_FOLDER}/lib/webc/errors.class.php

YESNO="Y"
if [ -f ${V_TARGET_FOLDER}/bootstrap.php ]; then
	echo -n "bootstrap.php's already existed, Overwrite?(Y/N)";
	read YESNO
fi
if [ "$YESNO" == "Y" ] || [ "$YESNO" == "y" ]; then
	php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} ${V_SCRIPT_FOLDER}/server/php/bootstrap_builder.tpl > ${V_TARGET_FOLDER}/bootstrap.php
fi
	
for V_APP_NAME in $(php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} ${V_SCRIPT_FOLDER}/helper/interfaces_enumerator.tpl)
do
	V_APP_PATH=$(dirname $(echo ${V_APP_NAME} | sed 's/\./\//g'))
	V_APP_FILE=$(basename $(echo ${V_APP_NAME} | sed 's/\./\//g'))".php"
	mkdir -p ${V_TARGET_FOLDER}/app/${V_APP_PATH}
	if [ -f ${V_TARGET_FOLDER}/app/${V_APP_PATH}/${V_APP_FILE} ]; then
		echo "skipping ${V_TARGET_FOLDER}/app/${V_APP_PATH}/${V_APP_FILE}";
	else
		php ${V_SCRIPT_FOLDER}/builder.php ${V_SOURCE_XML} ${V_SCRIPT_FOLDER}/server/php/application_builder.tpl ${V_APP_NAME} > ${V_TARGET_FOLDER}/${V_PROJECT_NAME}/app/${V_APP_PATH}/${V_APP_FILE}
	fi
done
echo "building done";
