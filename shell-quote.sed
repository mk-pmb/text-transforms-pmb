#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-
#
# NB: This is a fallback for when you can't use the advanced
#     implementation in `txtr.bins.pl`.
# NB: Run this with env var `LANG=C`!
#
/^$|[^A-Za-z0-9:,@\/=_\.\-]/{s~\x27+~\x27"&"\x27~g;s~^|$~\x27~g}
