#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
#$bin

function ensure_final_newline () {
  local MAX_SIZE=$(( 8 * 1024 * 1024 ))
  local FN= SZ= TAIL=
  for FN in "$@"; do
    [ -f "$FN" ] || continue
    SZ="$(stat -c %s -- "$FN")"
    [ -n "$SZ" ] || continue$(
      echo "W: $FUNCNAME: $FN: skip: cannot stat size" >&2)
    [ "$SZ" -le "$MAX_SIZE" ] || continue$(
      echo "W: $FUNCNAME: $FN: skip: scary huge file" >&2)
    TAIL="$(tail --bytes=1 -- "$FN"; echo :)"
    [ "$TAIL" == $'\n:' ] && continue
    echo >>"$FN" || return $?
  done
}


[ "$1" == --lib ] && return 0; ensure_final_newline "$@"; exit $?
