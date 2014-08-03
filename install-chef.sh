#!/bin/bash

D_R=`cd \`dirname $0\` ; pwd`

export PATH="/usr/local/bin:/usr/bin:$PATH"

which chef-solo 1>/dev/null 2>/dev/null && exit 0

if [ ! -f functions.sh ]; then
  curl -L https://raw.github.com/doubledrones/system_rescue_cd_tools/master/functions.sh -o $D_R/functions.sh
fi
source $D_R/functions.sh

OTHER="
eclass
"

DEPENDENCIES="
sys-devel/autoconf-wrapper
sys-devel/autoconf
dev-libs/libyaml
sys-devel/gettext
dev-perl/Locale-gettext
sys-apps/help2man
sys-devel/automake-wrapper
sys-devel/automake
dev-util/ragel
dev-ruby/json
dev-ruby/rake
virtual/rubygems
dev-ruby/racc
dev-ruby/rdoc
app-admin/eselect-ruby
dev-ruby/treetop
dev-ruby/mixlib-authentication
dev-ruby/ipaddress
dev-ruby/polyglot
dev-ruby/mixlib-cli
dev-ruby/bunny
dev-ruby/mixlib-config
dev-ruby/mixlib-log
dev-ruby/ohai
dev-ruby/amq-protocol
dev-ruby/mixlib-shellout
dev-ruby/moneta
dev-ruby/net-ssh
dev-ruby/net-ssh-multi
dev-ruby/ruby-shadow
dev-ruby/rest-client
dev-ruby/erubis
dev-ruby/yajl-ruby
dev-ruby/highline
dev-ruby/uuidtools
dev-ruby/mime-types
dev-libs/yajl
dev-util/cmake
dev-ruby/systemu
dev-ruby/net-ssh-gateway
dev-ruby/test-unit
dev-ruby/abstract
virtual/ruby-ssl
dev-libs/openssl
dev-lang/ruby
dev-ruby/rubygems
"

EBUILDS="
app-admin/chef
"

portage_part_sync $OTHER $DEPENDENCIES $EBUILDS

echo "dev-lang/ruby -berkdb ssl" >> /etc/portage/package.use
echo "=dev-ruby/rubygems-1.8.25 ~*" >> /etc/portage/package.keywords
echo ">dev-ruby/rubygems-1.8.25" >> /etc/portage/package.mask

if [ ! -f /usr/portage/dev-ruby/rubygems/rubygems-1.8.25.ebuild ]; then
  cd /usr/portage/dev-ruby/rubygems
  wget http://sources.gentoo.org/cgi-bin/viewvc.cgi/gentoo-x86/dev-ruby/rubygems/rubygems-1.8.25.ebuild || rm -f rubygems-1.8.25.ebuild
fi
if [ ! -f /usr/portage/distfiles/rubygems-1.8.25.tgz ]; then
  if [ ! -d /usr/portage/distfiles ]; then
    mkdir /usr/portage/distfiles/
  fi
  cd /usr/portage/distfiles/
  if [ ! -f rubygems-1.8.25.tgz ]; then
    wget http://production.cf.rubygems.org/rubygems/rubygems-1.8.25.tgz || rm -f rubygems-1.8.25.tgz
  fi
fi
ebuild /usr/portage/dev-ruby/rubygems/rubygems-1.8.25.ebuild digest

case `cat /etc/portage/package.mask | grep dev-lang/ruby` in
  "")
    ;;
  *)
    cat /etc/portage/package.mask | grep -v dev-lang/ruby > /tmp/package.mask
    mv /tmp/package.mask /etc/portage/package.mask
    ;;
esac

portage_emerge dev-libs/openssl
portage_emerge ruby:1.9

eselect ruby set ruby19

portage_emerge $EBUILDS
portage_cleanout $OTHER $DEPENDENCIES $EBUILDS
