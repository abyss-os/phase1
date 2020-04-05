#!/usr/bin/busybox ash

applets="$(/usr/bin/busybox --list)"

# evil
applet_exists() {
	local a=$1
	shift
	for i; do
		[[ "$a" = "$i" ]] && return 0
        done
	return 1
}

for l in $(find /usr/bin -type l); do
	a=${l##*/}
	if [ "$(readlink -nf /usr/bin/$a)" = "/usr/bin/busybox" ]; then
		applet_exists "$a" ${applets} || rm -f /usr/bin/"$a"
	fi
done


/usr/bin/busybox --install -s /usr/bin
