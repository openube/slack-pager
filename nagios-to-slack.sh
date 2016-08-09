#!/bin/bash

## Simple Nagios to Slack notification integration using Webhook
##
## TODO: Utilize $CONTACTADDRESSn$ Nagios macro to override destination channel.
##
## Nagios commands.cfg bits:
## # 'notify-service-by-slack' command definition
## define command {
##        command_name     notify-service-to-slack
##        command_line     /path/to/nagios-to-slack.sh
##        }
##
## # 'notify-host-by-slack' command definition
## define command {
##        command_name     notify-host-to-slack
##        command_line     /path/to/nagios-to-slack.sh
##        }
##
## Nagios contacts.cfg example:
## define contact {
##        contact_name                     slack
##        alias                            Slack
##        service_notification_period      24x7
##        host_notification_period         24x7
##        service_notification_options     u,c,r
##        host_notification_options        d,r
##        service_notification_commands    notify-service-to-slack
##        host_notification_commands       notify-host-to-slack
##       }
## Then add slack user to appropriate contact groups.

## Slack Hook and Channel
slackWebHook="https://hooks.slack.com/services/[WebHookLink]"
slackChannel="@[SlackUserName]"

## Nagios Server URL
NagiosStatusUri="https://yourNagiosHost/nagios/cgi-bin/status.cgi"

## Send a color coded message to Slack
function notifySlack () {
  status=$1
  hostname=$2
  servicename=$3
  result=$4

  case "${status}" in
    OK|UP)
      color="good"
      ;;
    WARNING)
      color="warning"
      ;;
    CRITICAL|DOWN)
      color="danger"
      ;;
    *)
      color="#909090"
      ;;
  esac

  payload="\"attachments\": [{ \"title\": \"${hostname} (${servicename}) is ${status}\", \"text\": \"${result} <https://${NagiosStatusUri}?host=${hostname}&style=detail\", \"color\": \"${color}\" }]"

  if [ ! -z "${slackChannel}" ]; then
     curl -s -XPOST --data-urlencode "payload={ \"channel\": \"${slackChannel}\", ${payload} }" ${slackWebHook} > /dev/null 2>&1
  else
     curl -s -XPOST --data-urlencode "payload={ ${payload} }" ${slackWebHook} > /dev/null 2>&1
  fi
}


## Is this a Service Check results or Host check result?
if [ -z "${NAGIOS_SERVICESTATE}" ]; then
    notifySlack "${NAGIOS_HOSTSTATE}" "${NAGIOS_HOSTNAME}" "Host Status" "${NAGIOS_HOSTOUTPUT}"
else
    notifySlack "${NAGIOS_SERVICESTATE}" "${NAGIOS_HOSTNAME}" "${NAGIOS_SERVICEDISPLAYNAME}" "${NAGIOS_SERVICEOUTPUT}"
fi
