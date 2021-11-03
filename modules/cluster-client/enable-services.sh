#!/bin/bash
set -e

chmod +x /opt/nomad/plugins/*

systemctl enable nomad
systemctl start nomad
systemctl restart nomad

systemctl enable consul 
systemctl start consul
systemctl restart consul

