#!/bin/sh
/usr/local/nagios/bin/nrpe -n -c /usr/local/nagios/etc/nrpe.cfg -d
/usr/bin/supervisord -n
