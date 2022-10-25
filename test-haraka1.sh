#!/bin/bash
sudo apt-get update && apt-get upgrade -y

#set your domain as a hostname:
hostnamectl set-hostname duffar.xyz
reboot now