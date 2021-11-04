#!/bin/bash
#Ensure services are up and running
set -e

systemctl enable nomad
systemctl start nomad
systemctl restart nomad

systemctl enable consul 
systemctl start consul
systemctl restart consul

