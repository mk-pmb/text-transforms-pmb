#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
#$bin

function oneline_alive () {
  if [ "$#" != 0 ]; then
    "$@" | oneline_alive
    return "${PIPESTATUS[0]}"
  fi

  local TTY_SIZE=( $(</dev/stdout tty --silent \
    && stty --file=/dev/stdout size | tr -cd '0-9 \n') )
  local LINE_WIDTH="${TTY_SIZE[1]}"
  [ "${LINE_WIDTH:-0}" -ge 72 ] || LINE_WIDTH=72
  local SIDES="($LINE_WIDTH - 4) / 2"
  let SIDES="$SIDES"
  sed -ure 's~^(.{'"$SIDES"'}).*(.{'"$SIDES"'})$~\1 … \2~
    s~^~ \r~;$!s~$~\x1b~' | discard_esc_eol
  return 0
}










[ "$1" == --lib ] && return 0; oneline_alive "$@"; exit $?
