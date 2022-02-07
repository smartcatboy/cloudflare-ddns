#! /bin/bash

ZONEID=""
RECORDID=""
TOKEN=""
DOMAIN=""

install_ddns_timer () {
    [[ ! -d /etc/systemd/system ]] && mkdir /etc/systemd/system
    tee /etc/systemd/system/ddns.service > /dev/null <<EOF
[Unit]
Description=DDNS for cloudflare by smartcatboy

[Service]
ExecStart=/usr/local/bin/ddns.sh
EOF
    tee /etc/systemd/system/ddns.timer > /dev/null <<EOF
[Unit]
Description=DDNS for cloudflare by smartcatboy

[Timer]
OnBootSec=60s
OnUnitActiveSec=60s
Unit=ddns.service

[Install]
WantedBy=timers.target
EOF
}

check_ddns_timer () {
    ! systemctl is-enabled --quiet ddns.timer > /dev/null 2>&1 && install_ddns_timer && \
    systemctl daemon-reload && \
    systemctl enable ddns.timer > /dev/null 2>&1 && \
    systemctl start ddns.timer > /dev/null 2>&1
}

install () {
    echo "开始安装 ..."
    [[ -z $ZONEID || -z $RECORDID || -z $TOKEN || -z $DOMAIN ]] && echo "请检查 TOKEN 等参数填写是否完整！" && exit 1
    ! curl --version > /dev/null 2>&1 && echo "请先安装 curl 后再执行脚本！" && exit 1
    [[ ! -d /usr/local/bin ]] && mkdir /usr/local/bin
    cp -f $(readlink -f $0) /usr/local/bin/ddns.sh
    chmod +x /usr/local/bin/ddns.sh
    check_ddns_timer
    echo "安装完成！"
}

update () {
    IPV6=$(curl -m 10 -s ipv6.ip.sb)
    [[ -z $IPV6 ]] && exit 1
    RECORD="{\"type\": \"AAAA\", \"name\": \"$DOMAIN\", \"content\": \"$IPV6\", \"ttl\": 1, \"proxied\": false}"
    curl -X PUT "https://api.cloudflare.com/client/v4/zones/$ZONEID/dns_records/$RECORDID/" \
        -H "Authorization: Bearer $TOKEN" \
        -H "Content-Type:application/json" \
        -d "$RECORD"
}

[[ ! -z $1 ]] && [[ $1 == "install" ]] && install && exit 0
update
