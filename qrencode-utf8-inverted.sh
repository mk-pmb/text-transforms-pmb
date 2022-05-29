#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
#$bin


function qrencode_utf8_inverted () {
  # By default, UTF8 output mode assumes bright on dark, as in traditional
  # terminal emulator defaults.
  # This script inverts it, to make the UTF8 image printable dark on bright.

  local SED='
    s~ |▄|▀|█~<&>~g
    s~< >~█~g
    s~<▄>~▀~g
    s~<▀>~▄~g
    s~<█>~ ~g
    '

  while [ "$#" -ge 1 ]; do
    case "$1" in
      --padded ) SED+='s~^~:\x1b[7m:  ~; s~$~  :\x1b[0m:  ~; '$'\n';;
      * ) break;;
    esac
    shift
  done

  local QR_OPTS=(
    --level=M
    --8bit
    --dpi=24
    --type=UTF8
    )
  qrencode "${QR_OPTS[@]}" "$@" | LANG=C sed -rf <(echo "$SED")
}



qrencode_utf8_inverted "$@"; exit $?
