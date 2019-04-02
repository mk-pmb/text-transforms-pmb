#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
source lib_demo_util.sh --lib || exit $?


function discard_esc_eol_wait () {
  chapter 'original:'
  ./dummy_log.py
  chapter 'compact:'
  ./dummy_log.py | sed -ure 's~(:|\.{3})$~& \x1b~' | discard_esc_eol
  return 0
}


discard_esc_eol_wait "$@"; exit $?
