#!/bin/bash

rm -fr /root/installer

sed -i '/deployer@deployer/d' /root/.ssh/authorized_keys
