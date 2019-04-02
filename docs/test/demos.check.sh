#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
SELFPATH="$(readlink -m "$0"/..)"


function check_demos () {
  cd "$SELFPATH"/../demo || return $?
  export DELAY=0
  export DEMO_CHAPTER_FMT='==----== %s ==----==\n'

  compare_cli_demo_output_pmb \
    --logs-prefix="$SELFPATH/" \
    [a-z]*.[a-z]*.sh \
    || return $?
  return 0
}


check_demos "$@"; exit $?
