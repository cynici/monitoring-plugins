#!/usr/bin/env bash

export PLUGINS="check_disk,check_dns,check_http,check_load,check_log,check_ntp,check_ntp_peer,check_ntp_time,check_ping,check_procs,check_smtp,check_snmp,check_ssh,check_swap,check_tcp,check_time,check_users,utils.sh"
export PLUGINS="check_mysql,check_mysql_query"
export SENSU_GO_ASSET_VERSION=$(git describe --abbrev=0 --tags)
export MONITORING_PLUGINS_VERSION=2.3

PLATFORMS='alpine amazon1 amazon2 debian8 debian9 debian10 centos6 centos7 centos8 ubuntu1404 ubuntu1604 ubuntu1804 ubuntu2004'
PLATFORMS='ubuntu1604 ubuntu1804 ubuntu2004'

mkdir assets/
for PLATFORM in $PLATFORMS;
do
  export SENSU_GO_ASSET_FILENAME="monitoring-plugins-${PLATFORM}_${SENSU_GO_ASSET_VERSION}_linux_amd64.tar.gz"
  docker build --no-cache --rm --build-arg "PLUGINS=$PLUGINS" --build-arg "SENSU_GO_ASSET_VERSION=$SENSU_GO_ASSET_VERSION" --build-arg "MONITORING_PLUGINS_VERSION=$MONITORING_PLUGINS_VERSION" -t monitoring-plugins-${PLATFORM}:$SENSU_GO_ASSET_VERSION -f Dockerfile.${PLATFORM} .
  # Doesn't work on MacOS because container vanishes before file is copied
  #docker cp -L $(docker create --rm monitoring-plugins-${PLATFORM}:$SENSU_GO_ASSET_VERSION true):/$SENSU_GO_ASSET_FILENAME ./assets/
  set -x
  docker run --rm -v $(pwd)/assets:/assets monitoring-plugins-${PLATFORM}:$SENSU_GO_ASSET_VERSION cp /$SENSU_GO_ASSET_FILENAME /assets/
  set +x
done;

cd assets/
export SENSU_GO_CHECKSUMS_FILENAME="monitoring-plugins_${SENSU_GO_ASSET_VERSION}_sha512-checksums.txt"
if [[ $(which sha512sum) ]]; then
  sha512sum ./*.tar.gz > $SENSU_GO_CHECKSUMS_FILENAME;
elif [[ $(which shasum) ]]; then
  shasum -a 512 *.tar.gz > $SENSU_GO_CHECKSUMS_FILENAME;
fi;
