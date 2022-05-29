#!/bin/bash
# -*- coding: utf-8, tab-width: 2 -*-
#$bin


function qrencode_utf8_inverted () {
  local QR_OPTS=(
    --level=M
    --8bit
    --dpi=24
    --type=UTF8
    )
  qrencode "${QR_OPTS[@]}" "$@" | LANG=C sed -rf <(echo '
    s~ |▄|▀|█~<&>~g
    s~< >~█~g
    s~<▄>~▀~g
    s~<▀>~▄~g
    s~<█>~ ~g
    s~^~:\x1b[7m:  ~
    s~$~  :\x1b[0m:  ~
    ')
}



qrencode_utf8_inverted "$@"; exit $?
