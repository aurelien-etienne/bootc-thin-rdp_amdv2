#!/usr/bin/env bash

set -xeuo pipefail

systemctl enable firewalld.service

firewall-offline-cmd --set-default-zone=drop
firewall-offline-cmd --zone=drop --remove-service-from-zone=ssh
firewall-offline-cmd --zone=trusted --add-service=ssh
