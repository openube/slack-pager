# slack-pager
Send alerts from monitoring systems to [Slack](https://slack.com/).

Most of the alerts are based on Slack's [Incoming Webhooks API](https://api.slack.com/incoming-webhooks).

## check-home.sh
Very basic two-step external validation that my home network is functional.  First, attempt and ssh, if that fails, then attempt ping.  Send a Slack direct message via Webhook if there is a state change since last check.

## nagios-to-slack.sh
Simple bash script to allow Nagios to send notifications directly to Slack.  Can either go to a #channel or @directMessage.

Nagios commands.cfg bits:
```
# 'notify-service-by-slack' command definition
define command {
       command_name     notify-service-to-slack
       command_line     /path/to/nagios-to-slack.sh
       }

# 'notify-host-by-slack' command definition
define command {
       command_name     notify-host-to-slack
       command_line     /path/to/nagios-to-slack.sh
       }
```

Nagios caontacts.cfg example:
```
define contact {
       contact_name                     slack
       alias                            Slack
       service_notification_period      24x7
       host_notification_period         24x7
       service_notification_options     u,c,r
       host_notification_options        d,r
       service_notification_commands    notify-service-to-slack
       host_notification_commands       notify-host-to-slack
      }
```
Then add slack user to appropriate contact groups.

