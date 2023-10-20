#!/bin/bash
cpu=$(arch)
systemctl stop naive
sleep 1
cp ./caddy/caddy.$cpu /usr/bin/caddy
sleep 1
systemctl start naive
systemctl stop naive3 && cp ./caddy/naive.$cpu /usr/bin/naive3 && systemctl start naive3 && systemctl status naive3
