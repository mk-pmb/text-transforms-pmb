#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
#$bin


function rev_domain () {
  local LN=
  while read -r LN; do
    <<<"$LN" sed -re 's~[:/\.]+~\n&\n~g' | tac | tr -d '\n'
    echo
  done
}


[ "$1" == --lib ] && return 0; rev_domain "$@"; exit $?
