#!/usr/bin/env bash
# -*- coding: UTF-8 -*-
set -e

# Setup
#python3 -m pip install --user --upgrade setuptools wheel
#python3 -m pip install --user --upgrade twine

# Build
python3 setup.py sdist bdist_wheel

# Updload
python3 -m twine upload dist/*
