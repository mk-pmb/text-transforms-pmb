#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
#$bin


function urlobfuscate_od () {
  # Inspiration:
  # https://github.com/nodejs/docker-node/issues/418#issuecomment-306032972

  local MAX_WIDTH=65536     # 256^2
  # Exceeding MAX_WIDTH makes my od print lots of % before the result.

  if [ "$#" == 0 ]; then
    od -An -v -t x1 -w65536 | tr ' ' '%'
    return $?
  fi

  local URL=
  for URL in "$@"; do
    echo -n "$URL" | "$FUNCNAME" || return $?
  done
  return 0
}










[ "$1" == --lib ] && return 0; urlobfuscate_od "$@"; exit $?
