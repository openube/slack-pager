#!/bin/bash

## Very basic check to see if home network is up.
## First attempt SSH connection to server.
## If this fails, then attempt to ping router.
## Record result of check to logfile.
## If current check status is different than last check status
##    sent message to Slack via webhook

## Host and SSH port to check
hName="[HostName]"
port="[Port]"

## Slack Hook and Channel
slackWebHook="https://hooks.slack.com/services/[WebHookLink]"
slackChannel="@[SlackUserName]"

## LogFile to maintain check state.
logFile="/[someLogDirectory/check-home.log"

## Send a color coded message to Slack
function notifySlack () {
  status=$1
  hostname=$2
  result=$3

  case "${status}" in
    OK)
      color="good"
      ;;
    WARNING)
      color="warning"
      ;;
    CRITICAL)
      color="danger"
      ;;
    *)
      color="#909090"
      ;;
  esac

  payload="\"attachments\": [{ \"title\": \"${hostname} status is ${status}\", \"text\": \"${result}\", \"color\": \"${color}\" }]"
  if [ ! -z "${slackChannel}" ]; then
     curl -s -XPOST --data-urlencode "payload={ \"channel\": \"${slackChannel}\", ${payload} }" ${slackWebHook} > /dev/null 2>&1
  else
     curl -s -XPOST --data-urlencode "payload={ ${payload} }" ${slackWebHook} > /dev/null 2>&1
  fi
}

## Get previous status
lastEvent=`tail -1 ${logFile}`
lastStatus=`echo ${lastEvent} | awk '{ print $4 }'`

### First Check Host if SSH is up.
results=`echo QUIT | nc -v -w 5 ${hName} ${port} 2>&1 | grep -v mismatch`
res=`echo ${results} | awk '{print $5}'`

## Check connection status, set to WARNING if this fails
if [ "${res}" != "open" ]; then
   echo `date +"%h %d %T"` WARNING $results >> ${logFile}
   status="WARNING"
   
   ## Try pinging host
   results2=`ping -c 5 ${hName} | grep packets`
   percent=`echo ${results2} | awk '{ print $6 }' | sed -e 's/\%//'`
   if [ "${percent}" -gt 0 ]; then
      echo `date +"%h %d %T"` CRITICAL $results2 >> ${logFile}
      status="CRITICAL"
   fi
else
   ## Otherwise we are okay
   echo `date +"%h %d %T"` OK $results >> ${logFile}
   status="OK"
fi

## Do we notify Slack?
if [ "${status}" != "${lastStatus}" ]; then
   results=`tail -1 ${logFile}`
   notifySlack "${status}" "${hName}" "${results}"
fi

