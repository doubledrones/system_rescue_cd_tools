#!/bin/bash

function default_portage_host() {
  USED=""
  for MIRROR in 1 2 3 4 5 6 7 8 9 10 11 12 13 14 15 16
  do
    case `echo $USED | grep " $MIRROR "` in
      "")
        USED="$USED $MIRROR "
        echo "rsync${MIRROR}.de.gentoo.org"
        return
        ;;
    esac
  done
  exit 2
}

function get_portage_host() {
  if [ -n "$LOCAL_PORTAGE_HOST" ]; then
    ping -c 1 $LOCAL_PORTAGE_HOST 1>/dev/null 2>/dev/null
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
    ERR=1
    while [ $ERR -gt 0 ]
    do
      mkdir -p /usr/portage/$EBUILD/
      rsync -av rsync://`get_portage_host`/gentoo-portage/$EBUILD/ /usr/portage/$EBUILD/
      ERR=$?
      if [ $ERR -gt 0 ]; then
        sleep 1
      fi
    done
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
    if [ ! -d /tmp/$EBUILD.finished ]; then
      RUBY_TARGETS="ruby19" MAKEOPTS="-j`make_jobs`" emerge --autounmask-write $EBUILD || exit 3
      rm -rf /usr/portage/distfiles || exit 4
      mkdir -p /tmp/$EBUILD.finished
    fi
  done
}

function portage_cleanout() {
  for EBUILD in $@
  do
    rm -rf /usr/portage/$EBUILD/ || exit 5
  done
}

function force_gem_install() {
  ERR=1
  while [ $ERR -gt 0 ]
  do
    gem install $1 --no-ri --no-rdoc
    ERR=$?
    if [ $ERR -gt 0 ]; then
      sleep 1
    fi
  done
}
