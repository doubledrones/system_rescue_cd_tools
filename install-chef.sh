#!/bin/bash

case "`which chef-solo`" in
  "")
    if [ ! -f functions.sh ]; then
      curl -L https://raw.github.com/doubledrones/system_rescue_cd_tools/master/functions.sh -o functions.sh
    fi
    source functions.sh

    OTHER="
    eclass
    "

    EBUILDS="
    dev-libs/openssl
    app-admin/eselect-ruby
    dev-lang/ruby
    dev-ruby/rubygems
    "

    PORTAGE_HOST=`get_portage_host`

    portage_part_sync $OTHER $EBUILDS

    echo "dev-lang/ruby -berkdb ssl" >> /etc/portage/package.use

    portage_emerge $EBUILDS
    portage_cleanout $OTHER $EBUILDS

    ERR=1
    while [ $ERR -gt 0 ]
    do
      gem install chef --no-ri --no-rdoc
      ERR=$?
      if [ $ERR -gt 0 ]; then
        sleep 1
      fi
    done
    ;;
esac
