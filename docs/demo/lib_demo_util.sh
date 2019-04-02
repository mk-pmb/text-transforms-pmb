#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-


function chapter () {
  [ -n "$DEMO_CHAPTER_FMT" ] \
    || local DEMO_CHAPTER_FMT='\n\x1b[1m»»» %s «««\x1b[0m\n'
  printf "$DEMO_CHAPTER_FMT" "$*"
}


function display_eol () {
  # Make EOL easy to spot in terminal output.
  chardict +nl nl='¶' cr='«'
}






[ "$1" == --lib ] && return 0; "$@"; exit $?
