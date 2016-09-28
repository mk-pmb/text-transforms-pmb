#!/usr/bin/python
# -*- coding: UTF-8, tab-width: 4 -*-

from __future__ import division
from os import getenv
from time import sleep
from sys import stdout

base_delay = float(getenv('DELAY', 0.25))

def slowprint(msg, effort=1, *args, **kwargs):
    stdout.write(msg.format(*args, **kwargs))
    stdout.flush()
    sleep(effort * base_delay)

slowprint('Resolve hostname... ', 2)
slowprint('512.0.0.-1:80\n')

def progressbar(cur, max, width=50):
    bar = ('=' * int(round((cur * width) / max))) + '>' + (' ' * width)
    bar = bar[0:width]
    return bar

blkcnt = 5
for blknum in xrange(0, blkcnt + 1):
    slowprint('\r[{bar}]  {prc:4.0%}', 2, bar=progressbar(blknum, blkcnt),
        prc=(blknum / blkcnt))
slowprint('\nFile saved.\n')
exit(0)
