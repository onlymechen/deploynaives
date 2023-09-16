#!/bin/bash
stty erase '^H'
iptables -I INPUT -p tcp --dport 80 -j ACCEPT
iptables -I INPUT -p tcp --dport 443 -j ACCEPT
iptables -I INPUT -p udp --dport 80 -j ACCEPT
iptables -I INPUT -p udp --dport 443 -j ACCEPT
bash -c "iptables-save > /etc/iptables/rules.v4"
mkdir -p /etc/caddy
mkdir -p /var/www/html/
cpu=$(arch)
caddypath=/usr/bin/caddy
cp ./caddy/caddy.$cpu $caddypath
chmod a+x $caddypath
read -p  "input dnsname:" dnsname
read -p  "input email:" mail
pass=$(echo $RANDOM |md5sum | cut -c 1-32)
webtext='This website only access use domain name. Pls use domain name access this webServer.'

cat > /etc/systemd/system/naive.service << "EOF"
[Unit]
Description=Caddy
Documentation=https://caddyserver.com/docs/
After=network.target network-online.target
Requires=network-online.target

[Service]
Type=notify
User=root
Group=root
ExecStart=/usr/bin/caddy run --environ --config /etc/caddy/Caddyfile
ExecReload=/usr/bin/caddy reload --config /etc/caddy/Caddyfile
TimeoutStopSec=5s
LimitNOFILE=1048576
LimitNPROC=512
PrivateTmp=true
ProtectSystem=full
AmbientCapabilities=CAP_NET_BIND_SERVICE

[Install]
WantedBy=multi-user.target
EOF

cat > /etc/caddy/Caddyfile << EOF
:443, $dnsname
tls $mail
route {
 forward_proxy {
   basic_auth user $pass
   hide_ip
   hide_via
   probe_resistance
  }
 forward_proxy {
   basic_auth user1 $pass
   hide_ip
   hide_via
   probe_resistance
  }
 forward_proxy {
   basic_auth user2 $pass
   hide_ip
   hide_via
   probe_resistance
  }
 forward_proxy {
   basic_auth user3 $pass
   hide_ip
   hide_via
   probe_resistance
  }
 forward_proxy {
   basic_auth chenyang $pass
   hide_ip
   hide_via
   probe_resistance
  }
  file_server {
    root /var/www/html
  }
}
EOF

echo $webtext > /var/www/html/index.html

cat > /root/config.json << EOF
{
  "listen": ["socks://0.0.0.0:1080", "http://0.0.0.0:1081"],
  "proxy": "https://user:$pass@$dnsname",
  "log": ""
}
EOF

##############start web#########################
systemctl enable naive
systemctl start naive
