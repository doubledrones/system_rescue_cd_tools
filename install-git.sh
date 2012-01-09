#!/bin/bash


case "`which git`" in
  "")
    source < <(curl -L https://raw.github.com/doubledrones/system_rescue_cd_tools/master/functions.sh)

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
