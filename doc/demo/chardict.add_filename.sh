#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
source lib_demo_util.sh --lib || exit $?


function chardict_add_filename_sh () {
  chapter 'original:'
  ./dummy_download.py
  chapter 'display EOL:'
  ./dummy_download.py | display_eol
  chapter 'add filename:'
  ./dummy_download.py | chardict +nl nl= cr='\r' | sed -ure '
    /\[.*\].*%\s*$/{
      # a line with a progress bar
      s~^~myfile.txt  ~
    }
    s~\r$~&\x1b~' | discard_esc_eol
  return 0
}


chardict_add_filename_sh "$@"; exit $?
