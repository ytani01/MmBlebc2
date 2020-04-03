#!/bin/sh
#
# (c) 2020 Yoichi Tanibayashi
#

CMD="MmBlebc2Publisher.py"
MACADDR="ac:23:3f:a0:08:ed"
TOKEN="token_VK8GQpDPFfDxZPGC"
CH="env1"
RES="temperature1 humidity1 battery1 msg1"
OLED="-o"

LOGFILE="${HOME}/tmp/${CMD}.log"

#
# functions
#
usage () {
    echo
    echo "  usage: ${MYNAME}"
    echo
}

ts_echo () {
    DATESTR=`date +'%Y/%m/%d(%a) %H:%M:%S'`
    echo "* ${DATESTR}> $*"
}

ts_echo_do () {
    ts_echo $*
    $*
    if [ $? -ne 0 ]; then
        ts_echo "ERROR: ${MYNAME}: failed"
        exit 1
    fi
}

#
# main
#
MYNAME=`basename $0`
ts_echo "MYNAME=${MYNAME}"

MYDIR=`dirname $0`
ts_echo "MYDIR=${MYDIR}"

cd $MYDIR
BASEDIR=`pwd`
ts_echo "BASEDIR=$BASEDIR"

if [ ! -z $1 ]; then
    usage
    exit 1
fi

VENVDIR=$(dirname $BASEDIR)
ts_echo "VENVDIR=$VENVDIR"

BINDIR="${VENVDIR}/bin"
ts_echo "BINDIR=$BINDIR"

#
# check venv and activate it
#
if [ -z ${VIRTUAL_ENV} ]; then
    ACTIVATE="${BINDIR}/activate"
    ts_echo "ACTIVATE=${ACTIVATE}"

    if [ ! -f ${ACTIVATE} ]; then
        ts_echo "${ACTIVATE}: no such file"
        exit 1
    fi
    . ${ACTIVATE}
fi
if [ ${VIRTUAL_ENV} != ${VENVDIR} ]; then
    ts_echo "VIRTUAL_ENV=${VIRTUAL_ENV} != ${VENVDIR}"
    exit 1
fi
ts_echo "VIRTUAL_ENV=${VIRTUAL_ENV}"

#
# check running
#
PID=`ps axw | grep -v grep | grep python3 | grep ${CMD} | sed 's/^ *//' | cut -d ' ' -f 1`
ts_echo "PID=${PID}"

#
# restart $CMD
#
if [ ! -z ${PID} ]; then
    ts_echo_do kill ${PID}
    ts_echo_do sleep 2
fi

CMDLINE="${CMD} ${MACADDR} ${TOKEN} ${CH} ${RES} ${OLED}"
ts_echo ${CMDLINE}
${CMDLINE} >> ${LOGFILE} 2>&1 &

ts_echo "done."
