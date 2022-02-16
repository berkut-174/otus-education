#!/usr/bin/env bash

semanage fcontext -a -t named_cache_t "/etc/named/dynamic(/.*)?"
restorecon -v -R /etc/named/dynamic
