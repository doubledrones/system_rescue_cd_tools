#!/bin/bash

D_R=`cd \`dirname $0\` ; pwd`

which ack 1>/dev/null 2>/dev/null && exit 0

if [ ! -f functions.sh ]; then
  curl -L https://raw.github.com/doubledrones/system_rescue_cd_tools/master/functions.sh -o $D_R/functions.sh
fi
source $D_R/functions.sh

OTHER="
eclass
dev-perl/File-Next
virtual/perl-Test-Simple
dev-lang/perl
app-admin/perl-cleaner
virtual/perl-File-Spec
"

EBUILDS="
sys-apps/ack
"

portage_part_sync $OTHER $EBUILDS

emerge -av "<sys-apps/ack-2"

portage_cleanout $OTHER $EBUILDS
