#!/bin/sed -urf
# -*- coding: UTF-8, tab-width: 2 -*-
#$bin

s~\b([0-9]{1,2})\.\s*(jan|feb|mar|m\S{0,2}rz|apr|ma[iy]|ju[nl]|aug|sep|okt|$\
  |nov|de[cz])[a-z]*\s*(19|20|)([0-9]{2})\b~\ny=\4\nm=\L\2\E\nd=0\1\n~ig

/\n/{
  s~(\nd=)0([0-9]{2})~\1\2~g
  s~(\nm=)jan~\101~g
  s~(\nm=)feb~\102~g
  s~(\nm=)(mar|m\S{0,2}rz)~\103~g
  s~(\nm=)apr~\104~g
  s~(\nm=)ma[iy]~\105~g
  s~(\nm=)jun~\106~g
  s~(\nm=)jul~\107~g
  s~(\nm=)aug~\108~g
  s~(\nm=)sep~\109~g
  s~(\nm=)okt~\110~g
  s~(\nm=)nov~\111~g
  s~(\nm=)de[cz]~\112~g
  s~\ny=([0-9]{2})\nm=([0-9]{2})\nd=([0-9]{2})\n~\1\2\3~g
  s~\n~~g
}
