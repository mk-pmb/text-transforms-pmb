#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
#$bin


function each_line_stdin () {
  local LN=
  while read -rs LN; do
    <<<"$LN" "$@" || return $?
  done
  return 0
}










[ "$1" == --lib ] && return 0; each_line_stdin "$@"; exit $?
