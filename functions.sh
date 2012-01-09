#!/bin/bash

function default_portage_host() {
  echo "rsync.gentoo.org"
}

function get_portage_host() {
  if [ -n "$LOCAL_PORTAGE_HOST" ]; then
    ping -c 5 $LOCAL_PORTAGE_HOST
    if [ $? -eq 0 ]; then
      echo "$LOCAL_PORTAGE_HOST"
    else
      default_portage_host
    fi
  else
    default_portage_host
  fi
}

function portage_part_sync() {
  for EBUILD in $@
  do
    mkdir -p /usr/portage/$EBUILD/ || exit 1
    rsync -av rsync://$PORTAGE_HOST/gentoo-portage/$EBUILD/ /usr/portage/$EBUILD/ || exit 2
  done
}

function make_jobs() {
  case `uname` in
    Linux)
      expr `cat /proc/cpuinfo | grep "^processor" | wc -l` \* 2 + 1
      ;;
    *)
      expr `sysctl -n hw.ncpu` \* 2 + 1
      ;;
  esac
}

function portage_emerge() {
  for EBUILD in $@
  do
    MAKEOPTS="-j`make_jobs`" emerge $EBUILD || exit 3
    rm -rf /usr/portage/distfiles || exit 4
  done
}

function portage_cleanout() {
  for EBUILD in $@
  do
    rm -rf /usr/portage/$EBUILD/ || exit 5
  done
}
