#!/usr/bin/perl
# -*- coding: UTF-8, tab-width: 2 -*-
#$bin
#
# A bit like tr (1), but can replace single chars with any length text,
# and tries to avoid buffering.
#

use strict;
use warnings;

use FindBin;
use lib "$FindBin::RealBin/lib/perl/";
use BackslashEscapesPmb;

use IO::File;

$| = 1;  # disable output buffering (tribute to perl 5.8.x)
binmode STDIN;
binmode STDOUT;

# Custom escapes: register slots and re-gen regexps before they're used
sub register_or_update_voc_char () {
  &BackslashEscapesPmb::addSpChars([$_[0], '1', 'voc']);
}
&register_or_update_voc_char('');


sub build_dict () {
  my $dict = {};
  my $arg = '';
  my $modes = { 'nl' => 0, 'unq' => 1, };
  while (@_ > 0) {
    $arg = shift;
    if ($arg eq '=') {
      $arg = shift;
      $arg .= '=' . shift;
    } elsif ("$arg" =~ m!^\+(nl|unq)$!s) {
      $modes->{$1} = 1;
      next;
    } elsif (substr($arg, 0, 2) eq '--') {
      if ($arg eq '--raw') {
        $modes->{'unq'} = 0;
      } elsif ($arg eq '--unquote') {
        $modes->{'unq'} = 1;
      } elsif ($arg eq '--add-nl') {
        $modes->{'nl'} = 1;
      } elsif ($arg eq '--exact') {
        $modes->{'unq'} = 0;
        $modes->{'nl'} = 0;
      } elsif ($arg eq '--vocfile') {
        $arg = shift;
        &learn_voc_file($dict, $arg);
      } else {
        die "E: unsupported option: $arg";
      }
      next;
    }
    if (&learn_voc_def($dict, $modes, '', $arg)) { next; }
    die "E: unsupported lesson format: $arg";
  }
  return $dict;
}


sub learn_voc_def () {
  my ($dict, $modes, $inchar, $outstr) = @_;
  unless (defined $outstr) {
    $outstr = $inchar;
    $inchar = '';
  }
  if ($inchar eq '') {
    if ($outstr =~ s!^\\x?([0-9a-fA-F]{2})=!!s) {
      $inchar = chr hex $1;
    } elsif ($outstr =~ s!^\\($BackslashEscapesPmb::SpCharsShortRgx)=!!s) {
      $inchar = $BackslashEscapesPmb::SpCharsShort->{$1};
    } elsif ($outstr =~ s!^($BackslashEscapesPmb::SpCharsLongRgx)=!!s) {
      $inchar = $BackslashEscapesPmb::SpCharsLong->{$1};
    } elsif ($outstr =~ s!^(.)=!!s) {
      $inchar = $1;
    } else {
      return 0
    }
  }
  &register_or_update_voc_char($inchar);
  if ($modes->{'unq'}) { $outstr = &BackslashEscapesPmb::unescape($outstr); }
  if ($modes->{'nl'}) { $outstr .= "\n"; }
  $dict->{$inchar} = $outstr;
  return 1;
}


sub learn_voc_file () {
  my ($dict, $vocfn) = @_;
  my $vocfh = new IO::File;
  open($vocfh, '<', $vocfn) or die("Cannot read voc file '$vocfn': $!");
  my ($lnum, $inchar, $outstr);
  $lnum = 0;
  while ($outstr = <$vocfh>) {
    $lnum += 1;
    if ("$outstr" =~ m!^\s*(#|;|$)!s) { next; }
    $outstr =~ s!\s+$!!s;
    if ($outstr =~ s!^\s*(\S+)\s+(\S+)$!$2!so) {
      $inchar = $1;
    } elsif ($outstr =~ s!^\s*(\S+)\s+[=:]\s+!!so) {
      $inchar = $1;
    } else {
      die "Unsupported definition syntax in voc file $vocfn:$lnum";
    }
    &learn_voc_def($dict, { 'unq' => 1 }, '', "$inchar=$outstr");
  }
  close($vocfh);
  return $dict;
}


sub translate () {
  my ($src_fh, $dict, $dest_fh) = @_;
  my $buf = '';
  my $esc_mode = 0;
  while (sysread($src_fh, $buf, 1) > 0) {
    if (exists $dict->{$buf}) { $buf = $dict->{$buf}; }
    print $dest_fh "$buf";
    flush $dest_fh;   # in case we might use sth. other than STDOUT some day
  }
  return 1;
}



&translate(\*STDIN, &build_dict(@ARGV), \*STDOUT);
exit 0;
