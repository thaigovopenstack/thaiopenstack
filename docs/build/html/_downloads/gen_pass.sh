#!/bin/sh
#
# Populate openstack database password
#

# Mainly inspired by
# sawangpong muadphet <sawangpong@itbakery.net>
#

file="passwordlist"
if [ -f passwordlist ]; then
  echo "Sorry, file exist"
  exit 1;
fi

SERVICES=(
        DB_PASS
        ADMIN_TOKEN
        ADMIN_PASS
        CEILOMETER_DBPASS
        CEILOMETER_PASS
        CINDER_DBPASS
        CINDER_PASS
        DASH_DBPASS
        DEMO_PASS
        GLANCE_DBPASS
        GLANCE_PASS
        HEAT_DBPASS
        HEAT_DOMAIN_PASS
        HEAT_PASS
        KEYSTONE_DBPASS
        NEUTRON_DBPASS
        NEUTRON_PASS
        NOVA_DBPASS
        NOVA_PASS
        RABBIT_PASS
        SWIFT_PASS
        AODH_DBPASS
        METADATA_SECRET
	      MANILA_DBPASS
	      MANILA_PASS
        TROVE_DBPASS
        TROVE_PASS
)

for i in ${SERVICES[@]}; do
        echo "export ${i}=$(openssl rand -hex 10)" >> passwordlist
done
exit 0
