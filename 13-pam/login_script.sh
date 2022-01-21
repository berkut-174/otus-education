#!/bin/bash -e

admin_group_name=admin

if [[ ! $(id -Gn "${PAM_USER}" | grep -w "${admin_group_name}") && "$(date +%u)" -gt 5 ]]
then
    exit 1
fi
