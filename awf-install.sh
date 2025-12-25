#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
## This script installs the 'awf' package by adding its PPA, updating the package list, and then installing the package.
echo -ex
sudo apt-add-repository ppa:flexiondotorg/awf
sudo apt update
sudo apt install awf
