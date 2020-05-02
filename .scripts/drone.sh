#!/bin/sh
[ -z "${DRONE_BUILD_EVENT}" ] && exit 1

echo "trigger: ${DRONE_BUILD_EVENT}"
echo "previous: ${DRONE_COMMIT_BEFORE}"
echo "current: ${DRONE_COMMIT_SHA}"

[ ! -z "${MC_HOST_master}" ] && echo "minio, activate!"

if [ "${DRONE_BUILD_EVENT}" = "push" ]; then
	mkdir -p ${HOME}/.abuild
	curl -sfLo ${HOME}/.abuild/${ABYSS_PRIVKEY} ${ABYSS_KEYBASE}/${ABYSS_PRIVKEY}\?c=${DRONE_COMMIT}
	curl -sfLo ${HOME}/.abuild/${ABYSS_PUBKEY} ${ABYSS_KEYBASE}/${ABYSS_PUBKEY}\?c=${DRONE_COMMIT}
	echo PACKAGER_PRIVKEY=${HOME}/.abuild/${ABYSS_PRIVKEY} > ${HOME}/.abuild/abuild.conf
else
	abuild-keygen -ain
fi

OPWD=${PWD}

case $DRONE_STAGE_ARCH in
	amd64) buildarch=x86_64;;
	arm64) buildarch=aarch64;;
	mips64) buildarch=mips64;;
	*) echo "unknown arch" ; exit 1;;
esac

apk --force-overwrite -U upgrade -a
apk add git minio-client

echo "=> nproc: $(nproc)"
echo "=> mem: $(grep MemTotal /proc/meminfo|awk '{print $2/1024}')"

for PKG in $(git log ...${DRONE_COMMIT_BEFORE} --format=format: --name-only | grep -e 'APKBUILD$' | tac); do
	if [ -f "${PKG}" ]; then
		apk --force-overwrite -U upgrade -a
		buildpkg=${PKG%APKBUILD}
		cd ${OPWD}/${buildpkg} || exit 1
		abuild -ri || exit 1
	fi
done
