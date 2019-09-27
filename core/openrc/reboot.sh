#!/bin/sh
if [ -z "$1" ]; then
	/sbin/openrc-shutdown -r now
else
	/sbin/openrc-shutdown -r $@
fi
