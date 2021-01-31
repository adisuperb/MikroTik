# jan/31/2021 10:07:49 by RouterOS 6.43.16
# software id = CTRR-JL8X
#
# model = RB941-2nD
# serial number = A1C30A222E83
/interface bridge
add admin-mac=74:4D:28:FE:D4:00 auto-mac=no comment=defconf disabled=yes \
    name=bridge
/interface ethernet
set [ find default-name=ether1 ] name=ether1-Modem
set [ find default-name=ether2 ] name=ether2-LAN
/interface list
add comment=defconf name=WAN
add comment=defconf name=LAN
/interface wireless security-profiles
set [ find default=yes ] supplicant-identity=MikroTik
add authentication-types=wpa-psk,wpa2-psk eap-methods="" \
    management-protection=allowed mode=dynamic-keys name=Kel.Mujino \
    supplicant-identity="" wpa-pre-shared-key=Adip.123 wpa2-pre-shared-key=\
    Adip.123
/interface wireless
set [ find default-name=wlan1 ] band=2ghz-b/g/n country=indonesia disabled=no \
    distance=indoors frequency=auto mode=ap-bridge security-profile=\
    Kel.Mujino ssid=Kel.Mujino wireless-protocol=802.11
/ip firewall layer7-protocol
add name=Steam regexp="^..+\\.(steam|valve|steampowered|steamcommunity|steamga\
    mes|steamusercontent|steamcontent|steamstatic).*\$"
/ip pool
add name=default-dhcp ranges=192.168.88.10-192.168.88.254
add name=Lokal ranges=192.168.10.2-192.168.10.254
add name=Wifi ranges=192.168.1.100-192.168.1.200
add name=dhcp_pool3 ranges=192.168.1.100-192.168.1.200
/ip dhcp-server
add address-pool=default-dhcp interface=bridge name=defconf
add address-pool=dhcp_pool3 disabled=no interface=wlan1 lease-time=1w name=\
    dhcp1
/queue simple
add max-limit=1M/10M name=Global priority=1/1 target=192.168.10.0/24
add max-limit=512k/1M name=Other packet-marks=other-pk parent=Global target=\
    192.168.10.0/24
add max-limit=512k/1M name="Global WiFi" priority=1/1 target=wlan1
add max-limit=512k/1M name="Other WiFi" packet-marks=other-pk parent=\
    "Global WiFi" target=wlan1
add disabled=yes max-limit=5M/5M name=LAN target=192.168.10.2/32
add disabled=yes max-limit=8k/8k name=WIFI target=wlan1
add max-limit=512k/1M name="Browsing Wifi" packet-marks=http-pk parent=\
    "Global WiFi" target=wlan1
add limit-at=1M/10M max-limit=1M/10M name=Steam packet-marks=steam-pk parent=\
    Global priority=1/1 queue=default/default target=192.168.10.0/24
add limit-at=512k/2M max-limit=512k/2M name=Browsing packet-marks=http-pk \
    parent=Global priority=5/5 queue=default/default target=192.168.10.0/24
add limit-at=1M/10M max-limit=1M/10M name="Steam WiFi" packet-marks=steam-pk \
    parent="Global WiFi" priority=1/1 queue=default/default target=wlan1
/queue tree
add disabled=yes name=PING_MULUS packet-mark=PING_PAKET parent=global \
    priority=1 queue=default
/interface bridge port
add bridge=bridge comment=defconf interface=ether2-LAN
add bridge=bridge comment=defconf interface=ether3
add bridge=bridge comment=defconf interface=ether4
add bridge=bridge comment=defconf interface=wlan1
/ip neighbor discovery-settings
set discover-interface-list=LAN
/interface list member
add comment=defconf interface=bridge list=LAN
add comment=defconf interface=ether1-Modem list=WAN
/ip address
add address=192.168.10.1/24 comment=Lokal interface=ether2-LAN network=\
    192.168.10.0
add address=192.168.1.1/24 comment=Wifi interface=wlan1 network=192.168.1.0
add address=192.168.100.254/24 comment=WAN interface=ether1-Modem network=\
    192.168.100.0
/ip dhcp-client
add dhcp-options=hostname,clientid interface=wlan1
/ip dhcp-server network
add address=192.168.1.0/24 gateway=192.168.1.1
add address=192.168.10.0/24 comment=Lokal dns-server=192.168.10.1 gateway=\
    192.168.10.1 netmask=24
add address=192.168.88.0/24 comment=defconf gateway=192.168.88.1
/ip dns
set allow-remote-requests=yes servers=192.168.100.1
/ip dns static
add address=192.168.10.1 name=Lokal
add address=192.168.0.0 name=Wifi
/ip firewall filter
add action=fasttrack-connection chain=forward comment="defconf: fasttrack" \
    connection-state=established,related
add action=accept chain=forward src-address=192.168.0.0/24
add action=accept chain=forward comment="defconf: accept in ipsec policy" \
    disabled=yes ipsec-policy=in,ipsec
add action=accept chain=forward comment="defconf: accept out ipsec policy" \
    disabled=yes ipsec-policy=out,ipsec
add action=accept chain=input comment=\
    "defconf: accept established,related,untracked" connection-state=\
    established,related,untracked disabled=yes
add action=accept chain=input comment="defconf: accept ICMP" disabled=yes \
    protocol=icmp
add action=drop chain=input comment="defconf: drop invalid" connection-state=\
    invalid disabled=yes
add action=accept chain=forward comment=\
    "defconf: accept established,related, untracked" connection-state=\
    established,related,untracked disabled=yes
add action=drop chain=forward comment="defconf: drop invalid" \
    connection-state=invalid disabled=yes
add action=drop chain=input comment="defconf: drop all not coming from LAN" \
    disabled=yes in-interface-list=!LAN
add action=drop chain=forward comment=\
    "defconf:  drop all from WAN not DSTNATed" connection-nat-state=!dstnat \
    connection-state=new disabled=yes in-interface-list=WAN
/ip firewall mangle
add action=mark-connection chain=prerouting comment=PING_STABIL disabled=yes \
    new-connection-mark=PING_STABIL passthrough=yes protocol=icmp
add action=mark-packet chain=prerouting comment=PING_PAKET connection-mark=\
    PING_STABIL disabled=yes new-packet-mark=PING_PAKET passthrough=no \
    protocol=icmp
add action=mark-connection chain=forward comment="Steam UDP Ports" \
    new-connection-mark=steam-conn passthrough=yes port=\
    27000-28999,3478,4379,4380 protocol=udp
add action=mark-connection chain=forward comment="Steam TCP Ports" dst-port=\
    27015,27036,27037 new-connection-mark=steam-conn passthrough=yes \
    protocol=tcp
add action=mark-connection chain=forward comment="Steam L7" layer7-protocol=\
    Steam new-connection-mark=steam-conn passthrough=yes protocol=tcp
add action=mark-connection chain=forward comment="Steam https" dst-port=443 \
    new-connection-mark=steam-conn passthrough=yes protocol=tcp tls-host=\
    *steam*
add action=mark-packet chain=forward comment=all-steam-pk connection-mark=\
    steam-conn new-packet-mark=steam-pk passthrough=no
add action=mark-connection chain=forward comment="http-conn 80" dst-port=80 \
    new-connection-mark=http-conn passthrough=yes protocol=tcp
add action=mark-connection chain=forward comment="http-conn 443" dst-port=443 \
    new-connection-mark=http-conn passthrough=yes protocol=tcp
add action=mark-packet chain=forward comment=http-pk connection-mark=\
    http-conn new-packet-mark=http-pk passthrough=no
add action=mark-connection chain=forward comment=other-conn \
    new-connection-mark=other-conn passthrough=yes
add action=mark-packet chain=forward comment=other-pk connection-mark=\
    other-conn new-packet-mark=other-pk passthrough=no
/ip firewall nat
add action=masquerade chain=srcnat ipsec-policy=out,none
/ip route
add distance=1 gateway=192.168.100.1
add distance=1 gateway=192.168.10.68
add distance=1 gateway=192.168.0.254
add distance=1 gateway=192.168.0.1
add distance=1 gateway=192.168.100.1
/system clock
set time-zone-name=Asia/Jakarta
/system identity
set name=AdiP
/system ntp client
set enabled=yes primary-ntp=162.159.200.123 secondary-ntp=114.141.48.158 \
    server-dns-names=0.id.pool.ntp.org,1.id.pool.ntp.org
/tool mac-server
set allowed-interface-list=LAN
/tool mac-server mac-winbox
set allowed-interface-list=LAN
