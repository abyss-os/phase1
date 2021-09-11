#!/bin/sh
[ -z "${DRONE_BUILD_EVENT}" ] && exit 1

echo "trigger: ${DRONE_BUILD_EVENT}"
echo "previous: ${DRONE_COMMIT_BEFORE}"
echo "current: ${DRONE_COMMIT_SHA}"

[ ! -z "${MC_HOST_master}" ] && echo "minio, activate!"

if [ "${DRONE_BUILD_EVENT}" = "push" ]; then
	mkdir -p ${HOME}/.abuild
	echo "=> privkey"
	curl -4sfLo ${HOME}/.abuild/${ABYSS_PRIVKEY} ${ABYSS_KEYBASE}/${ABYSS_PRIVKEY}\?c=${DRONE_COMMIT} || exit 1
	echo "=> pubkey"
	curl -4sfLo ${HOME}/.abuild/${ABYSS_PUBKEY} ${ABYSS_KEYBASE}/${ABYSS_PUBKEY}\?c=${DRONE_COMMIT} || exit 1
	echo PACKAGER_PRIVKEY=${HOME}/.abuild/${ABYSS_PRIVKEY} > ${HOME}/.abuild/abuild.conf
else
	abuild-keygen -ain
fi

OPWD=${PWD}

# can't even remember why this was added in the first place
case $DRONE_STAGE_ARCH in
	amd64) buildarch=x86_64;;
	arm64) buildarch=aarch64;;
	*) buildarch=$DRONE_STAGE_ARCH;;
esac

apk add git minio-client

echo "=> nproc: $(nproc)"
echo "=> mem: $(grep MemTotal /proc/meminfo|awk '{print $2/1024}')"

for PKG in $(git log ...${DRONE_COMMIT_BEFORE} --format=format: --name-only | grep -e 'APKBUILD$' | tac); do
	if [ -f "${PKG}" ]; then
		apk --force-refresh --force-overwrite -U upgrade -a
		buildpkg=${PKG%APKBUILD}
		cd ${OPWD}/${buildpkg} || exit 1
		abuild -ri || exit 1
	fi
done

rm -rf /var/cache/distfiles/*
