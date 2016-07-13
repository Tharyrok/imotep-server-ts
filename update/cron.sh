#!/bin/bash
set -e

ROOT="/home/teamspeak"
ROOT_SRV="${ROOT}/server"
ROOT_SCRIPT="${ROOT}/update"

GET_ALL_VERSIONS=$(wget -q -O- http://dl.4players.de/ts/releases/ | grep -oP "href=\"((\d{1,2}\.){1,4}\d{1,3})" | grep -oP "((\d{1,2}\.){1,4}\d{1,3})" | sort -V | tac)

for VERSION in ${GET_ALL_VERSIONS}
do
	if wget -q --spider "http://dl.4players.de/ts/releases/${VERSION}/teamspeak3-server_linux_amd64-${VERSION}.tar.bz2"
	then
		break
	fi
done


if [[ -f "${ROOT_SCRIPT}/version" ]]
then
	CURRENT_VERSION=$(cat "${ROOT_SCRIPT}/version")
else
	CURRENT_VERSION=""
fi


if(! [[ ${CURRENT_VERSION} = ${VERSION} ]] )
then
	/usr/bin/supervisorctl stop teamspeak
	wget -q -O"${ROOT_SCRIPT}/teamspeak3-server_linux_amd64-${VERSION}.tar.bz2" "http://dl.4players.de/ts/releases/${VERSION}/teamspeak3-server_linux_amd64-${VERSION}.tar.bz2"
	tar -xf "${ROOT_SCRIPT}/teamspeak3-server_linux_amd64-${VERSION}.tar.bz2" --strip-components=1 -C "${ROOT_SRV}"
	rm -f "${ROOT_SCRIPT}/teamspeak3-server_linux_amd64-${VERSION}.tar.bz2"
	echo -n ${VERSION} > "${ROOT_SCRIPT}/version"
	/usr/bin/supervisorctl start teamspeak
fi
