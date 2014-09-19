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
mkdir -p ${V_TARGET_FOLDER}/${V_PROJECT_NAME}/app

php ${V_SCRIPT_FOLDER}/php/structure_builder.php ${V_SOURCE_XML} > ${V_TARGET_FOLDER}/${V_PROJECT_NAME}/lib/structures.class.php
php ${V_SCRIPT_FOLDER}/php/interface_builder.php ${V_SOURCE_XML} > ${V_TARGET_FOLDER}/${V_PROJECT_NAME}/lib/interfaces.class.php
php ${V_SCRIPT_FOLDER}/php/bootstrap_builder.php ${V_SOURCE_XML} > ${V_TARGET_FOLDER}/${V_PROJECT_NAME}/bootstrap.php
for V_APP_NAME in $(php ${V_SCRIPT_FOLDER}/php/applist_builder.php ${V_SOURCE_XML})
do
	V_APP_PATH=$(dirname $(echo ${V_APP_NAME} | sed 's/\./\//g'))
	V_APP_FILE=$(basename $(echo ${V_APP_NAME} | sed 's/\./\//g'))".php"
	mkdir -p ${V_TARGET_FOLDER}/${V_PROJECT_NAME}/app/${V_APP_PATH}
	if [ -f ${V_TARGET_FOLDER}/${V_PROJECT_NAME}/app/${V_APP_PATH}/${V_APP_FILE} ]; then
		echo "skipping ${V_TARGET_FOLDER}/${V_PROJECT_NAME}/app/${V_APP_PATH}/${V_APP_FILE}";
	else
		php ${V_SCRIPT_FOLDER}/php/appdetail_builder.php ${V_SOURCE_XML} ${V_APP_NAME} > ${V_TARGET_FOLDER}/${V_PROJECT_NAME}/app/${V_APP_PATH}/${V_APP_FILE}
	fi
done
echo "building done";
