#!/bin/bash
STRINGS=(
  $'wait… \rwaited.\n'
  $'lf:\n'
  $'cr+lf:\r\n'
  $'no eol:'
)
printf %s "${STRINGS[@]}"; exit $?
