#!/bin/bash

function gentoo_rsync_mirror_hosts() {
  curl http://www.gentoo.org/main/en/mirrors-rsync.xml | grep 'a href="rsync:' | cut -f 2 -d \"  | cut -f3- -d /
}

function default_portage_host() {
  USED=" "
  for MIRROR_HOST in `gentoo_rsync_mirror_hosts`
  do
    case `echo $USED | grep " $MIRROR_HOST "` in
      "")
        USED="$USED $MIRROR_HOST "
        echo $MIRROR_HOST
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
    if [ ! -d /tmp/portage-synced/$EBUILD/ ]; then
      ERR=1
      while [ $ERR -gt 0 ]
      do
        mkdir -p /usr/portage/$EBUILD/
        rsync -av rsync://`get_portage_host`/gentoo-portage/$EBUILD/ /usr/portage/$EBUILD/
        ERR=$?
        if [ $ERR -gt 0 ]; then
          sleep 1
        else
          mkdir -p /tmp/portage-synced/$EBUILD/
        fi
      done
    fi
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
      ACCEPT_KEYWORDS="~*" RUBY_TARGETS="ruby19" MAKEOPTS="-j`make_jobs`" emerge --autounmask-write $EBUILD || exit 3
      rm -rf /usr/portage/distfiles || exit 4
      mkdir -p /tmp/$EBUILD.finished
    fi
  done
}

function portage_cleanout() {
  for EBUILD in $@
  do
    rm -rf /usr/portage/$EBUILD/ || exit 5
    rm -rf /tmp/portage-synced/$EBUILD/ || exit 6
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
