#!/bin/bash -e
if [ "$DEBUG" = "true" ] ; then
  export PS4='+(${BASH_SOURCE}:${LINENO}): ${FUNCNAME[0]:+${FUNCNAME[0]}(): }'
  set -x
fi
#########################################
JOBS_STATUS_0='Unexpanded'
JOBS_STATUS_1='Idle'
JOBS_STATUS_2='Running'
JOBS_STATUS_3='Removed'
JOBS_STATUS_4='Completed'
JOBS_STATUS_5='Held'
JOBS_STATUS_6='Submission_Error'
JOBS_STATUS_='Unknown'

WAIT_GAP=60
ERROR_COUNT=0
MAX_ERROR_COUNT=5
WORKSPACE="${WORKSPACE-$PWD}"
JOB_NAME="${JOB_NAME-job}"
BUILD_NUMBER="${BUILD_NUMBER-0}"
REQUEST_CPUS="${REQUEST_CPUS-1}"
REQUEST_UNIVERSE="${REQUEST_UNIVERSE-vanilla}"
REQUEST_MAXRUNTIME="${REQUEST_MAXRUNTIME-432000}"
DEBUG="${DEBUG-false}"
JENKINS_CALLBACK="${JENKINS_CALLBACK-http://cmsjenkins03.cern.ch:8080/jenkins/}"

if [ $REQUEST_CPUS -lt 1 ] ; then REQUEST_CPUS=1 ; fi
if [ $REQUEST_MAXRUNTIME -lt 3600 ] ; then REQUEST_MAXRUNTIME=3600 ; fi
##########################################
here=$(dirname $0)
cd $WORKSPACE
mkdir -p logs

script_name=${JOB_NAME}-${BUILD_NUMBER}.$(date +%Y%m%d%H%M%S)
SLAVE_JAR_DIR="${WORKSPACE}"
while [ ! -e ${SLAVE_JAR_DIR}/slave.jar ] ; do
  SLAVE_JAR_DIR=$(dirname $SLAVE_JAR_DIR)
done
cp $SLAVE_JAR_DIR/slave.jar slave.jar
cp ${here}/connect.sub job.sub
cp ${here}/connect-job.sh  ${script_name}.sh
chmod +x ${script_name}.sh

sed -i -e "s|@SCRIPT_NAME@|${script_name}|"             job.sub
sed -i -e "s|@REQUEST_CPUS@|$REQUEST_CPUS|"             job.sub
sed -i -e "s|@REQUEST_UNIVERSE@|$REQUEST_UNIVERSE|"     job.sub
sed -i -e "s|@REQUEST_MAXRUNTIME@|$REQUEST_MAXRUNTIME|" job.sub
echo "environment = \"EXTRA_LABELS='${EXTRA_LABELS}' JENKINS_CALLBACK=${JENKINS_CALLBACK} REQUEST_MAXRUNTIME=${REQUEST_MAXRUNTIME}\"" >> job.sub

if [ "X${CONDOR_JOB_CONF}" != "X" ] ; then
  if [ -f  ${CONDOR_JOB_CONF} ] ; then
    cat ${CONDOR_JOB_CONF} >> job.sub
  else
    echo "ERROR: Missing condor job configuration file : ${CONDOR_JOB_CONF}"
    exit 1
  fi
fi
echo "queue 1" >> job.sub
echo "############# JOB Configuration file ###############"
cat job.sub
echo "####################################################"

condor_submit -spool ${CONDOR_SUBMIT_OPTIONS} job.sub > submit.log 2>&1 || true
cat submit.log
JOBID=$(grep ' submitted to cluster ' submit.log | sed 's|.* ||;s| ||g;s|\.$||')
if [ "$JOBID" = "" ] ; then exit 1 ; fi
sleep $WAIT_GAP
echo "$JOBID" > job.id

EXIT_CODE=1
PREV_JOB_STATUS=""
KINIT_COUNT=0
kinit -R
while true ; do
  JOB_STATUS=$(condor_q -json -attributes JobStatus $JOBID | grep 'JobStatus' | sed 's|.*: *||;s| ||g')
  eval JOB_STATUS_MSG=$(echo \$$(echo JOBS_STATUS_${JOB_STATUS}))
  if [ "${PREV_JOB_STATUS}" != "${JOB_STATUS}${ERROR_COUNT}" ] ; then
    echo "Job Status(${ERROR_COUNT}): $JOB_STATUS: ${JOB_STATUS_MSG}"
    PREV_JOB_STATUS="${JOB_STATUS}${ERROR_COUNT}"
  fi
  if [ "$JOB_STATUS" = "1" -o "$JOB_STATUS" = "2" ] ;  then
    ERROR_COUNT=0
    if [ "$JOB_STATUS" = "2" ] ;  then exit 0 ; fi
  elif [ "$JOB_STATUS" = "4" ] ; then
    EXIT_CODE=$(condor_q -json -attributes ExitCode $JOBID | grep 'ExitCode' | sed 's|.*: *||;s| ||g')
    break
  elif [ "$JOB_STATUS" = "3" -o "$JOB_STATUS" = "6" -o "$JOB_STATUS" = "0" ] ;  then
    ERROR_COUNT=$MAX_ERROR_COUNT
  else
    if [ "$JOB_STATUS" = "5" ] ; then condor_q -json -attributes HoldReason $JOBID | grep 'HoldReason' | sed 's|"||g;s|^ *HoldReason: *||' || true ; fi
    let ERROR_COUNT=$ERROR_COUNT+1
  fi
  if [ $ERROR_COUNT -ge $MAX_ERROR_COUNT ] ; then
    condor_q -json -attributes $JOBID || true
    break
  fi
  sleep $WAIT_GAP
  let KINIT_COUNT=KINIT_COUNT+1
  if [ $KINIT_COUNT -ge 120 ] ; then
    KINIT_COUNT=0
    kinit -R
    klist
  fi
done
echo EXIT_CODE $EXIT_CODE
condor_transfer_data $JOBID || true
ls -l
if [ -f log.stdout ] ; then cat log.stdout ; fi
condor_rm $JOBID || true
condor_q
exit $EXIT_CODE

