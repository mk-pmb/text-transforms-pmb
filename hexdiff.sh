#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
#$bin


function hexdiff () {
  local -A CFG=(
    [diff-prog]=diff
    )
  </dev/null colordiff &>/dev/null && CFG[diff-prog]=colordiff
  CFG[width]=120
  local DIFF_OPTS=(
    # --side-by-side --width="${CFG[width]}"
    -U 2
    )

  local OPT=
  while [ "$#" -gt 0 ]; do
    CFG[oldfn]="${CFG[newfn]}"
    CFG[newfn]=
    if [ "$OPT" == -- ]; then CFG[newfn]="$1"; shift; else
      OPT="$1"; shift
      case "$OPT" in
        '' ) continue;;
        -- ) ;;
        --help | \
        -* )
          local -fp "${FUNCNAME[0]}" | guess_bash_script_config_opts-pmb
          [ "${OPT//-/}" == help ] && return 0
          echo "E: $0, CLI: unsupported option: $OPT" >&2; return 1;;
        * ) CFG[newfn]="$OPT";;
      esac
    fi
    [ -n "${CFG[oldfn]}" ] || continue
    # echo "D: ${CFG[oldfn]} <-> ${CFG[newfn]}" >&2
    "${CFG[diff-prog]}" "${DIFF_OPTS[@]}" \
      --label="${CFG[oldfn]}" <(hexdiff_dump "${CFG[oldfn]}") \
      --label="${CFG[newfn]}" <(hexdiff_dump "${CFG[newfn]}")
  done

  if [ -z "${CFG[oldfn]}" ]; then
    if [ -z "${CFG[newfn]}" ]; then
      tty --silent && echo 'I: reading input from stdin.' >&2
      CFG[newfn]=/dev/stdin
    fi
    hexdiff_dump "${CFG[newfn]}" || return $?
  fi
}


function hexdiff_dump () {
  hd -v -- "$1"
}


function hexdiff_dump__orig_old_171217 () {
  local TRANSFORMS=(
    --hex-backslash-nonascii
    --count-repeats-bslast 1 4 5
    )
  <"$1" text-transforms-pmb "${TRANSFORMS[@]}" | LANG=C sed -rf <(echo '
    s~\\x0A~¶\n~g
    s~\\x20~ ~g
    : wrap
      s~(^|\n)([^\n]{40,50}[^\\])([^\n]{5,})~\1\2\n\3~
    t wrap
    ${/\n$/!s~$~\n~}
    ')
}










[ "$1" == --lib ] && return 0; hexdiff "$@"; exit $?
