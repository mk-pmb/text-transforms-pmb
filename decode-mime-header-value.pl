#!/usr/bin/perl
# -*- coding: UTF-8, tab-width: 2 -*-
#$bin
use strict;
use warnings;
use MIME::EncWords 'decode_mimewords';
foreach my $orig (@ARGV) {
  my @parts = decode_mimewords($orig);
  # ^-- I need this temporary array to force array context.
  print(join('', map { $_->[0] } @parts), "\n");
}
