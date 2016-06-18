#!/bin/bash
#
# Template for multiple run prevention
# for BASH scripts
#


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++ ENVIROMENT ++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# set debug mode
readonly DEBUG=1

# set max working time of script in seconds
readonly MAX_WORKING_TIME=5

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++ DECLARATIONS ++++++++++++++++++++++++++++++++++++++
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# Set working directory use actual directory
readonly WORKDIR=$(pwd)

# get scriptname and remove dir part
readonly SCRIPTNAME_WITH_EXTENTION=${0##*/}

# remove extension from scriptname
readonly SCRIPTNAME=${SCRIPTNAME_WITH_EXTENTION%.*}

# set logfile name with dailysuffix
readonly LOGFILE=${WORKDIR}/${SCRIPTNAME}$(date +'_%Y_%m_%d').log

# set working file name for multiple run prevention
# use scriptname with _working suffix
readonly WORKING_FILE=${WORKDIR}/.${SCRIPTNAME}_working


# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++ FUNCTIONS +++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# debug printig
#
# Parameter:
# $1 string which is printed with timestamp in debug mode
#
# Info:
# 1. if global DEBUG is 1 print debug message
# 2. if global DEBUG is 0 do nothing
#
function decho(){

local STRING=$1

if [ $DEBUG -eq 1 ]
	then :
	echo -e "$(date '+%F %T'): ${STRING}"
	echo -e "$(date '+%F %T'): ${STRING}" >>${LOGFILE}
fi

unset STRING
}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# timestamp printig
#
# Parameter:
# $1 string which is printed with timestamp
#
# Info:
# 1. print string with timestamp
#
function techo(){

local STRING=$1

echo -e "$(date '+%F %T'): ${STRING}"
echo -e "$(date '+%F %T'): ${STRING}" >>${LOGFILE}

unset STRING
}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++


# remove_file
#
# Parameter:
# $1 full filepath
#
# Info:
# 1. remove file $1
#
function remove_file(){

local FUNCTION_TEMP_FILE=${1}

if [ -f ${FUNCTION_TEMP_FILE} ]
then :
	decho "DEBUG: file ${FUNCTION_TEMP_FILE} exists"
	decho "DEBUG: removing file ${FUNCTION_TEMP_FILE}"
	rm ${FUNCTION_TEMP_FILE}
else :
	techo "ERROR: $(date '+%F %T'): ERROR: file ${FUNCTION_TEMP_FILE} not exists"
fi

unset FUNCTION_TEMP_FILE

}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# check_working
#
# Parameter:
# $1 Name of working file
# $2 max age of working file in seconds
#
# Info:
# 1. check if script already working
# 2. write working file with exclusive filehandle
# 3. if working file is older than n seconds delete working file
# 4. if filehandle can not taken exit
#
function check_working(){

# save paramter temporary
FUNCTION_WORKING_FILE=${1}
TEMP_MAX_AGE=${2}

# check if working file already exists
if [ -f ${FUNCTION_WORKING_FILE} ]
then :
	# get age of working file in seconds
	WORKING_FILE_AGE=$(expr $(date +%s) - $(date +%s -r ${FUNCTION_WORKING_FILE}))

	# check if working file older then TEMP_MAX_AGE
	if [ ${WORKING_FILE_AGE} -gt ${TEMP_MAX_AGE} ] # this nooooot working
	then :
		techo "WARN: working file ${FUNCTION_WORKING_FILE} is older than ${TEMP_MAX_AGE}"
		techo "WARN: deleting old working file ${FUNCTION_WORKING_FILE}"
		rm ${FUNCTION_WORKING_FILE}
	else
		decho "DEBUG: working file ${FUNCTION_WORKING_FILE} found"
		techo "WARN: script is already working"
		decho "WARN: exit script"
		exit 1
	fi
else :
	decho "DEBUG: working file ${FUNCTION_WORKING_FILE} not found all ok"
fi


# open file descriptor
exec 200>$FUNCTION_WORKING_FILE

# get exclusiv file lock or exit
flock -n 200 || (techo "FATAL: filehandle on working file can not be opend" && exit 1)

# cleanup wokring file when script is exiting
trap 'remove_file ${FUNCTION_WORKING_FILE}' EXIT 0

# get script pid
local PID=$$

# print pid in working file
echo $PID 1>&200

}

# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++
# ++++++ MAIN ++++++++++++++++++++++++++++++++++++++++++++++
# ++++++++++++++++++++++++++++++++++++++++++++++++++++++++++

# multiple run prevention
check_working ${WORKING_FILE} ${MAX_WORKING_TIME}


## TEST
