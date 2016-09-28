#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
SELFPATH="$(readlink -m "$BASH_SOURCE"/..)"
INVOKED_AS="$(basename "$0" .sh)"


function pipe_helper () {
  local FLT_CMD=()
  local IN_CMD=()
  case "$INVOKED_AS" in
    pipe-nonl )   FLT_CMD=( chardict nl= );;
    pipe-noeol )  FLT_CMD=( chardict nl= cr= );;
    pipe-nl2sp )  FLT_CMD=( chardict nl=' ' );;
    show-wsp )    FLT_CMD=( chardict --vocfile
                    "$SELFPATH/doc/demo/chardict.whitespace.txt" );;
    * ) echo "E: $0: unsupported invocation" >&2; return 1;;
  esac
  IN_CMD+=( "$@" )
  if [ -z "${IN_CMD[0]}" ]; then
    exec "${FLT_CMD[@]}"
    RV=$?
  fi

  "$@" | "${FLT_CMD[@]}"
  local RV="${PIPESTATUS[*]}"
  let RV="${RV// /+}"
  return "$RV"
}








pipe_helper "$@"; exit $?
