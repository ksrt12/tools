#!/bin/sh
opkg update;
echo "#### Install packages";
opkg install luci luci-i18n-wireguard-ru luci-i18n-base-ru curl ipset nano-full htop;

if [ ! -e /etc/init.d/unblock ]; then
echo "### Add script"
cat <<EOF > /etc/init.d/unblock
#!/bin/sh

dir=/tmp/lst
mkdir -p \$dir

all=\$dir/all.lst

echo "Run download lists"
curl -z \$all https://antifilter.download/list/allyouneed.lst --output \$all

echo "Create temporary sets"
ipset create vpn_all || true
ipset destroy -q vpn_all_tmp || true
ipset create vpn_all_tmp hash:net

echo "Fill temporary sets"
cat \$dir/all.lst | xargs -n1 ipset add vpn_all_tmp

echo "Swap with real sets"
ipset swap vpn_all_tmp vpn_all
ipset destroy vpn_all_tmp
EOF
fi;

chmod +x /etc/init.d/unblock;
if [ ! -e /etc/rc.d/S99unblock ]; then
echo "#### Symlink to rc.d";
ln -s /etc/init.d/unblock /etc/rc.d/S99unblock;
fi;

echo "#### Enable cron";
/etc/init.d/cron enable;
/etc/init.d/cron start;

if [ "`grep 'vpn' /etc/iproute2/rt_tables`" == "" ]; then
echo "#### Add VPN table";
echo "99    vpn" >> /etc/iproute2/rt_tables
fi;

if [ ! -e /etc/hotplug.d/iface/30-vpn ]; then
echo "#### Add route";
cat <<EOF > /etc/hotplug.d/iface/30-vpn
#!/bin/sh

ip route add table vpn default dev wg0
EOF
fi;

if [ "`grep 'wg0' /etc/config/network`" == "" ]; then
echo "#### Add wireguard interface"
cat <<EOF >> /etc/config/network
config interface 'wg0'
	option proto 'wireguard'
	option private_key '8IJ00VL/NJNmBt5O0MrC4hgW/5cmuXeYq8gP9b3P/k4='
	list addresses '10.0.0.10/32'
	option auto '0'

config wireguard_wg0
	option public_key 'RPAWnQt4dwzWMLY2BOnuISfHHMW+3W5sBHy1vYJK8Fo='
	list allowed_ips '0.0.0.0/0'
	option endpoint_host '176.124.207.214'
	option endpoint_port '51835'
	option persistent_keepalive '25'

config rule
	option priority '100'
	option lookup 'vpn'
	option mark '0x1'
EOF
fi;

if [ "`grep 'wg0' /etc/config/firewall`" == "" ]; then
echo "#### Add firewall rules";
cat <<EOF >> /etc/config/firewall
config zone
	option name 'wg'
	option family 'ipv4'
	option masq '1'
	option output 'ACCEPT'
	option forward 'REJECT'
	option input 'REJECT'
	option mtu_fix '1'
	list network 'wg0'

config forwarding
	option src 'lan'
	option dest 'wg'

config ipset
	option name 'vpn_all'
	option match 'dest_net'
	option family 'ipv4'
	option storage 'hash'
	option loadfile '/tmp/lst/all.lst'

config rule
	option name 'Mark-VPN-Subnets'
	option src 'lan'
	option dest '*'
	option proto 'all'
	option ipset 'vpn_all'
	option set_xmark '0x1'
	option family 'ipv4'
	option target 'MARK'
EOF
fi;

echo "#### Reboot..."
reboot

