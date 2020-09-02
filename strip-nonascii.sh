#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
#$bin
LANG=C LC_CTYPE=C exec sed -re 's~[^\t\r\n -~]~~g' "$@"
