#!/bin/bash

D_R=`cd \`dirname $0\` ; pwd`

which vbetool 1>/dev/null 2>/dev/null && exit 0

if [ ! -f functions.sh ]; then
  curl -L https://raw.github.com/doubledrones/system_rescue_cd_tools/master/functions.sh -o $D_R/functions.sh
fi
source $D_R/functions.sh

OTHER="
eclass
"

DEPENDENCIES="
sys-devel/autoconf-wrapper
sys-devel/automake-wrapper
sys-devel/gettext
sys-devel/autoconf
dev-perl/Locale-gettext
sys-apps/help2man
sys-devel/automake
"

EBUILDS="
sys-apps/vbetool
"

portage_part_sync $OTHER $DEPENDENCIES $EBUILDS

portage_emerge $EBUILDS
portage_cleanout $OTHER $DEPENDENCIES $EBUILDS
