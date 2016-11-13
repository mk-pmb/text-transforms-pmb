#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
source lib_demo_util.sh --lib || exit $?


function chardict_add_filename_sh () {
  local VOC_FN="${0%.sh}.txt"
  local VOCS_FROM_FILE=(
    nl='¶\n'
    cr='«'
    sp='·'
    tab='»\1'
    bel='¡'
    )
  local DUMMY_DATA=$'EHLO\r\n250 tabs\ttab\r' # final \n is added by "<<<"

  chapter 'raw:'
  echo "$DUMMY_DATA"
  chapter 'cli dict:'
  <<<"$DUMMY_DATA" chardict "${VOCS_FROM_FILE[@]}"
  chapter 'file dict:'
  <<<"$DUMMY_DATA" chardict --vocfile "$VOC_FN"
  return 0
}


chardict_add_filename_sh "$@"; exit $?
