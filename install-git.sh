#!/bin/bash

D_R=`cd \`dirname $0\` ; pwd`

case "`which git`" in
  "")
    if [ ! -f functions.sh ]; then
      curl -L https://raw.github.com/doubledrones/system_rescue_cd_tools/master/functions.sh -o $D_R/functions.sh
    fi
    source $D_R/functions.sh

    OTHER="
    eclass
    "

    EBUILDS="
    dev-vcs/git
    "

    portage_part_sync $OTHER $EBUILDS

    portage_emerge $EBUILDS
    portage_cleanout $OTHER $EBUILDS
    ;;
esac
