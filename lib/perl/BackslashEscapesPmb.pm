# -*- coding: UTF-8, tab-width: 2 -*-

package BackslashEscapesPmb;

use strict;
use warnings;

BEGIN {
  require Exporter;
  our $VERSION     = 0.01;
  our @ISA         = qw(Exporter);
  our @EXPORT      = qw();
  our @EXPORT_OK   = qw(
    $SpCharsShort
    $SpCharsShortRgx
    $SpCharsLong
    $SpCharsLongRgx
    addSpChars
    unescape
    );
}


our $SpCharsShort = {
  'Z' => "\x00",
  'a' => "\a", 'b' => "\b", 'e' => "\e", 'f' => "\f",
  's' => ' ',  'n' => "\n", 'r' => "\r", 't' => "\t", 'v' => "\x0B",
  'A' => "'",  'Q' => '"',  'B' => "\\",
  };
map { $SpCharsShort->{$_} = $_; } qw= \ " ' & @ ^ $ =;

our $SpCharsLong = {
  'nul'  => "\x00",
  'bel'  => "\a", 'bsp'  => "\b", 'esc' => "\e", 'ff'  => "\f",
  'sp'   => ' ',  'nl'   => "\n", 'cr'  => "\r", 'tab' => "\t", 'vt' => "\x0B",
  'apos' => "'",  'quot' => '"',  'bsl' => "\\", 'eq'  => '=',
  'amp'  => '&',  'usd'  => '$',  'at'  => '@',  'prc' => '%',
  'pipe' => '|',  'excl' => '!',  'qm'  => '?',  'smc' => ';',
  'circ' => '^',
  };


our ($SpCharsShortRgx, $SpCharsLongRgx);
sub addSpChars () {
  my ($spChar, @spcNames, $spcName, $spcNameLen);
  foreach $spChar (@_) {
    @spcNames = @{$spChar};
    $spChar = shift @spcNames;
    foreach $spcName (@spcNames) {
      $spcNameLen = length $spcName;
      if ($spcNameLen == 1) { $SpCharsShort->{$spcName} = $spChar; }
      if ($spcNameLen > 1) { $SpCharsLong->{$spcName} = $spChar; }
    }
  }
  $SpCharsShortRgx = '[' . quotemeta(join('', keys %{$SpCharsShort})) . ']';
  $SpCharsLongRgx = '(?:' . join('|', keys %{$SpCharsLong}) . ')';
}
&addSpChars();


sub unescape () {
  my ($text, $bsl_char) = @_;
  if (not defined $bsl_char) {
    $text =~ s!\\($SpCharsShortRgx|x)([0-9a-fA-F]*)!&unescape($2, $1)!seg;
  } elsif ($bsl_char eq 'x') {
    $text = chr hex $text;
  } else {
    $text = $SpCharsShort->{$bsl_char} . $text;
  }
  return $text;
}













1;
