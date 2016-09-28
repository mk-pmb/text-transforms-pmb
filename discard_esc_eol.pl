#!/usr/bin/perl
# -*- coding: UTF-8, tab-width: 2 -*-
#$bin

use strict;
$| = 1;  # disable output buffering (tribute to perl 5.8.x)
binmode STDIN;
binmode STDOUT;

my $buf = '';
my $esc_mode = 0;
while (sysread(STDIN, $buf, 1) > 0) {
  if ($buf eq "\e") {
    $esc_mode = 1;
    next;
  } elsif (($buf eq "\r") or ($buf eq "\n")) {
    if ($esc_mode) { next; }
  }
  $esc_mode = 0;
  print "$buf";
  flush STDOUT;   # should be no-op due to $|
}
