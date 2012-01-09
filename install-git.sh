#!/bin/bash


case "`which git`" in
  "")
    if [ ! -f functions.sh ]; then
      curl -L https://raw.github.com/doubledrones/system_rescue_cd_tools/master/functions.sh -o functions.sh
      source functions.sh
    fi


    OTHER="
    eclass
    "

    EBUILDS="
    dev-vcs/git
    "

    PORTAGE_HOST=`get_portage_host`

    portage_part_sync $OTHER $EBUILDS

    portage_emerge $EBUILDS
    portage_cleanout $OTHER $EBUILDS
    ;;
esac
