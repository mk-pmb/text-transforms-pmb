#!/usr/bin/perl
# -*- coding: UTF-8, tab-width: 2 -*-
use strict;
use warnings;


&reg_tr(
  ['identity',  [], sub () { $_[0] }],
  ['reverse',   [], sub () { join '', reverse split m'', $_[0]; }],
  ['strlen',    [], sub () { length $_[0]; }],

  ['lc',      [], sub () { lc $_[0]; }],
  ['uc',      [], sub () { uc $_[0]; }],
  ['lc1st',   [], sub () { lcfirst $_[0]; }],
  ['uc1st',   [], sub () { ucfirst $_[0]; }],

  ['trim',    [], sub () { $_[0] =~ s~^\s+|\s+$~~sogr; }],
  ['ltrim',   [], sub () { $_[0] =~ s~^\s+~~sor; }],
  ['rtrim',   [], sub () { $_[0] =~ s~\s+$~~sor; }],
  ['add-nl',  [], sub () { $_[0] . "\n"; }],
  ['add-lf',  [], sub () { $_[0] . "\n"; }],

  ['add-default-space', sub () {
    my $argn = 0;
    return sub () {
      my ($buf, $opts) = @_;
      $argn += 1;
      if ($opts->{'cli_input_argc'} > 0) {
        # assume all input came from CLI.
        if ($argn > 1) { $buf = ' ' . $buf; }
      } else {
        # assume all input came from STDIN.
        $buf .= "\n";
      }
      return $buf;
    };
  }],

  ['count-repeats-bslast', ['min_len', 'max_len', 'min_cnt'], sub () {
    my ($min_len, $max_len, $min_cnt) = @_;
    return sub () {
      $_[0] =~ s|((\\?[^\\]{$min_len,$max_len})(?:\2){$min_cnt,})|
        "\\*" . ( (length $1) / (length $2) ) . ":" . $2 . "\\*:" |siegr;
    }
  }],

);












return 1;
