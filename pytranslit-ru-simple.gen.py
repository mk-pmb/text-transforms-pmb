#!/usr/bin/python3
# -*- coding: UTF-8, tab-width: 4 -*-

import sys
import transliterate # sudo apt-get install python3-transliterate
import unicodedata

print('#!/bin/sed -urf')
print('# -*- coding: UTF-8, tab-width: 2 -*-')
print('#$bin')

for i in range(0x400, 0x500):
    c = chr(i)
    # if unicodedata.combining(c): continue
    # if unicodedata.category(c).startswith('C'): continue
    t = transliterate.translit(c, 'ru', reversed=True)
    if t == c: continue
    if not t.isalpha(): continue
    print('s:' + c + ':' + t + ':g')
