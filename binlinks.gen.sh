#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
SELFFILE="$(readlink -m "$0")"; SELFPATH="$(dirname "$SELFFILE")"
SELFNAME="$(basename "$SELFFILE" .sh)"; INVOKED_AS="$(basename "$0" .sh)"


function gen_binlinks_file () {
  cd "$SELFPATH" || return $?
  local RUNMODE="${1:-gen}"; shift
  case "$RUNMODE" in
    gen ) ;;
    func:* ) "${RUNMODE#*:}" "$@"; return $?;;
    * ) echo "E: $0, CLI: unsupported runmode: $RUNMODE" >&2; return 1;;
  esac

  local SRC_FN='text-transforms.pl'
  local DEST_FN="${SELFNAME%.gen}.cfg"

  sed -nre '2s~$~\n#\n# !! generated !!\n#\n~p' -- "$SELFFILE" >"$DEST_FN"
  echo "${SRC_FN%.*}-pmb <- $SRC_FN" >>"$DEST_FN"
  local SRC_SIZE="$(stat -c %s "$SRC_FN")"
  [ "${SRC_SIZE:-0}" -gt 0 ] || return 3$(echo "E: failed to stat $SRC_FN" >&2)

  local MAXLN="$SRC_SIZE"
  local TRANSFORMS=()
  readarray -t TRANSFORMS < <(find_txtr_bin_names | sort -V)
  local TRANSFORM=
  for TRANSFORM in "${TRANSFORMS[@]}"; do
    echo "$TRANSFORM <- $SRC_FN" >>"$DEST_FN" || return $?
  done
  echo >>"$DEST_FN"

  invoke_cases >>"$DEST_FN"

  grep -HPe '^\#\$bin' *.{pl,py,sh} 2>/dev/null | sed -nrf <(<<<'
    s~^(æ)(\.[a-z]+):#\$bin$~\1 <- \1\2~p
    ' sed -re '
    s~æ~[a-z0-9_-]+~g
    ') >>"$DEST_FN"

  return 0
}


function find_txtr_bin_names () {
  sed -nre '
    : skip
      /^\&reg_tr\(/b reg_tr
      n
    b skip
    : reg_tr
      /^\)\;$/b skip
      s~^\s*\[\x27([a-z0-9_-]+)\x27,.*$~\1~p
      n
    b reg_tr
    ' -- txtr.bins.pl
}


function invoke_cases () {
  local CASE_RGX='\s*case "\$INVOKED_AS" in'
  local PROGS=()
  readarray -t PROGS < <(grep -lxPe "$CASE_RGX" -- *.sh)
  local ALIASES=()
  local ALIAS=
  local PROG=
  local MAXLN=9002
  local ALIAS_RGX='[a-z0-9_-]+'
  local ALIASES_SED='
    s~^((\s|'"$ALIAS_RGX"'|\|)+)\s*\)(|\s.*)$~\1\n~
    /\n$/!d
    : unor
      s~(^|\n)(\s+)('"$ALIAS_RGX"')\s*\|\s*~\1\2\3\n\2~g
    t unor
    s!^\s+!!;s!\s+$!!;s!\s+!\n!g
    '
  for PROG in "${PROGS[@]}"; do
    readarray -t ALIASES < <(grep -xPe "$CASE_RGX" -m 1 -A $MAXLN -- "$PROG" \
      | grep -Pe '^\s*esac($|\s|;)' -m 1 -B $MAXLN | sed -re "$ALIASES_SED")
    [ -n "${ALIASES[*]}" ] || continue
    for ALIAS in "${ALIASES[@]}"; do
      echo "$ALIAS <- $PROG"
      ALIAS=
    done
    echo
  done
}










gen_binlinks_file "$@"; exit $?
