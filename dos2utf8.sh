#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
#$bin

function dos2utf8 () {
  iconv --from-code CP850 --to-code UTF-8 "$@"
  return $?
}


[ "$1" == --lib ] && return 0; dos2utf8 "$@"; exit $?
