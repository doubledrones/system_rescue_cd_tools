#!/bin/bash

D_R=`cd \`dirname $0\` ; pwd`

case "`which chef-solo`" in
  "")
    if [ ! -f functions.sh ]; then
      curl -L https://raw.github.com/doubledrones/system_rescue_cd_tools/master/functions.sh -o $D_R/functions.sh
    fi
    source $D_R/functions.sh

    OTHER="
    eclass
    "

    EBUILDS="
    sys-devel/autoconf
    dev-libs/libyaml
    sys-devel/gettext
    dev-perl/Locale-gettext
    sys-apps/help2man
    sys-devel/automake
    dev-util/ragel
    dev-ruby/json
    dev-ruby/rake
    virtual/rubygems
    dev-ruby/racc
    dev-ruby/rdoc
    dev-libs/openssl
    app-admin/eselect-ruby
    dev-lang/ruby
    dev-ruby/rubygems
    "

    portage_part_sync $OTHER $EBUILDS

    echo "dev-lang/ruby -berkdb ssl" >> /etc/portage/package.use

    case `cat /etc/portage/package.mask | grep dev-lang/ruby` in
      "")
        ;;
      *)
        cat /etc/portage/package.mask | grep -v dev-lang/ruby > /tmp/package.mask
        mv /tmp/package.mask /etc/portage/package.mask
        ;;
    esac

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
