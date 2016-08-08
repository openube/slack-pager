# slack-pager
Send alerts from monitoring systems to [Slack](https://slack.com/).

Most of the alerts are based on Slack's [Incoming Webhooks API](https://api.slack.com/incoming-webhooks).

## check-home.sh
Very basic two-step external validation that my home network is functional.  First, attempt and ssh, if that fails, then attempt ping.  Send a Slack direct message via Webhook if there is a state change since last check.

