#!/bin/sh
[ -z "${BUILD_DEFINITIONNAME}" ] && exit 1

if [ "$USER" != "root" ]; then
	sudo $0
	exit
fi

echo "trigger: ${BUILD_REASON}"
echo "commit: ${BUILD_SOURCEVERSION}"

[ ! -z "${MC_HOST_master}" ] && echo "minio, activate!"

mkdir -p ${HOME}/.abuild
curl -Lo ${HOME}/.abuild/${ABYSS_PRIVKEY} ${ABYSS_KEYBASE}/${ABYSS_PRIVKEY}\?c=${BUILD_SOURCEVERSION}
curl -Lo ${HOME}/.abuild/${ABYSS_PUBKEY} ${ABYSS_KEYBASE}/${ABYSS_PUBKEY}\?c=${BUILD_SOURCEVERSION}
echo PACKAGER_PRIVKEY=${HOME}/.abuild/${ABYSS_PRIVKEY} >> ${HOME}/.abuild/abuild.conf

OPWD=${PWD}

case $AGENT_OSARCHITECTURE in
	X64) buildarch=x86_64;;
	*) echo "unknown arch" ; exit 1;;
esac

apk --force-overwrite -U upgrade -a
apk add git minio-client

for PKG in $(git log ...${DRONE_COMMIT_BEFORE} --format=format: --name-only | grep -e 'APKBUILD$' | tac); do
	if [ -f "${PKG}" ]; then
		apk --force-overwrite -U upgrade -a
		buildpkg=${PKG%APKBUILD}
		cd ${OPWD}/${buildpkg} || exit 1
		abuild -ri || exit 1
	fi
done
