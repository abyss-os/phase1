#!/bin/sh
for i in "$@"; do
	case "$i" in
		/lib/modules/*)
			if [ -d "$i" ]; then
				/bin/busybox depmod ${i#/lib/modules/}
			fi
			;;
		*) echo nothing;;
	esac
done
