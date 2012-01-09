#!/bin/bash

D_R=`cd \`dirname $0\` ; pwd`

case "`which sudo`" in
  "")
    if [ ! -f functions.sh ]; then
      curl -L https://raw.github.com/doubledrones/system_rescue_cd_tools/master/functions.sh -o $D_R/functions.sh
    fi
    source $D_R/functions.sh

    OTHER="
    eclass
    "

    EBUILDS="
    sys-devel/bison
    net-mail/mailbase
    mail-mta/ssmtp
    app-admin/sudo
    "

    PORTAGE_HOST=`get_portage_host`

    portage_part_sync $OTHER $EBUILDS

    echo "sys-devel/bison -nls" >> /etc/portage/package.use
    echo "mail-mta/ssmtp -ipv6 mta -ssl" >> /etc/portage/package.use

    portage_emerge $EBUILDS
    portage_cleanout $OTHER $EBUILDS
    ;;
esac
