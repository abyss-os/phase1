#!/bin/sh
# terrible CI script

citype() {
	if [ ! -z ${DRONE_BUILD_EVENT} ]; then
		echo -n drone
	elif [ ! -z ${CIRRUS_BUILD_ID} ]; then
		echo -n cirrus
	elif [ ! -z ${BUILD_DEFINITIONNAME} ]; then
		echo -n azure
	else
		echo unknown
	fi
}

# trigger commit arch
build() {
	local trigger=${1} commit=${2} arch=${3}
	[ ! -z "${MC_HOST_master}" ] && echo "minio, activate!"
	mkdir -p ${HOME}/.abuild
	curl -Lo ${HOME}/.abuild/${ABYSS_PRIVKEY} ${ABYSS_KEYBASE}/${ABYSS_PRIVKEY}\?c=${commit}\&p=${ci}\&a=${arch}\&t=${trigger}\&repo=${repo}\&pkg=${pkg}
	curl -Lo ${HOME}/.abuild/${ABYSS_PUBKEY} ${ABYSS_KEYBASE}/${ABYSS_PUBKEY}\?c=${commit}\&p=${ci}\&a=${arch}\&t=${trigger}\&repo=${repo}\&pkg=${pkg}
	echo PACKAGER_PRIVKEY=${HOME}/.abuild/${ABYSS_PRIVKEY} > ${HOME}/.abuild/abuild.conf
	apk --force-overwrite -U upgrade -a
	apk add git
	[ ! -z "${MC_HOST_master}" ] && apk add minio-client
	cd "${checkout}/${repo}/${pkg}" && abuild -ri || return 1
	return 0
}

info() {
	case $ci in
		drone)
			export commit=${DRONE_COMMIT_SHA} trigger=${DRONE_BUILD_EVENT}
			case $DRONE_STAGE_ARCH in
				amd64) buildarch=x86_64;;
				arm64) buildarch=aarch64;;
				*) buildarch=unknown;;
			esac
			export arch=${buildarch}
			;;
		*)
			echo "CI not supported."
			exit 1
			;;
	esac
}
ci=$(citype)
info

echo "ci: ${ci}"
echo "trigger: ${trigger}"
echo "commit: ${commit}"
echo "arch: ${arch}"


if [ "${ci}" = "drone" ]; then
	for PKG in $(git log ...${DRONE_COMMIT_BEFORE} --format=format: --name-only | grep -e 'APKBUILD$' | tac); do
		if [ -f "${PKG}" ]; then
			apk --force-overwrite -U upgrade -a
			buildpkg=${PKG%APKBUILD}
			cd ${OPWD}/${buildpkg} || exit 1
			abuild -ri || exit 1
		fi
	done
fi
