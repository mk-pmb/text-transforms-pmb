#!/usr/bin/python
# -*- coding: UTF-8, tab-width: 4 -*-

from __future__ import division
from os import getenv
from time import sleep
from sys import stdout

actions = [
    ('generate fake data...', 6, 'generated.'),
    ('feed it to cat (1)...', 4, 'input came out unchanged.'),
    ('delete spam:', 8, 'done, using best herbal mail enhancements.'),
    ]

base_delay = float(getenv('DELAY', 0.25))
for action, effort, result in actions:
    print action; stdout.flush()
    sleep(effort * base_delay)
    print result; stdout.flush()
    sleep(base_delay)
exit(0)
