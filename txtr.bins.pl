#!/usr/bin/perl
# -*- coding: UTF-8, tab-width: 2 -*-
use strict;
use warnings;


my $rgx_ranges = {
  'non_ascii_bytes' => '\x00-\x08\x0B-\x1F\x5C\x7F-\xFF',
};

$rgx_ranges->{'non_ascii_bytes_and_c_escapes'} = ('\0\a\b\e\f\n\r\t\v'
  . $rgx_ranges->{'non_ascii_bytes'});

sub fac_str2id () {
  my $sepchar = shift;
  return sub () {
    $_[0] =~ s![^A-Za-z0-9]+!_!sog;
    $_[0] =~ s!^_!!so;
    $_[0] =~ s!_$!!so;
    $_[0] =~ s!_!$sepchar!sgr;
  };
}


sub zerofill_even () {
  my $x = shift;
  if ((length $x) % 2) { return '0' . $x; }
  return $x;
}


&reg_tr(
  ['json-str-quote', sub () {
    require JSON;
    my $json = JSON->new->allow_nonref;
    return sub () { $json->encode($_[0]); };
  }],

  ['json-str-unquote', sub () {
    require JSON;
    my $json = JSON->new->allow_nonref;
    return sub () { $json->decode($_[0]); };
  }],

  ['shell-quote', [], sub () {
    my ($arg) = @_;
    if ($arg eq '') { return "''"; }
    if ("$arg" =~ m|[^A-Za-z0-9:,@/=_\.\-]|s) {
      $arg =~ s|'+|'"$&"'|sg;
      return "'$arg'";
    }
    return $arg;
  }, ':cli-space'],

  ['hex-backslash-bytes', [], sub () {
    $_[0] =~ s|(.)|sprintf '\\x%02X', (ord $1)|siegr;
  }],

  ['hex-backslash-nonascii', [], sub () {
    $_[0] =~ s|([$rgx_ranges->{'non_ascii_bytes'}])|
      sprintf '\\x%02X', (ord $1)|siegr;
  }],

  ['hex-backslash-nonascii-and-c', [], sub () {
    $_[0] =~ s|([$rgx_ranges->{'non_ascii_bytes_and_c_escapes'}])|
      sprintf '\\x%02X', (ord $1)|siegr;
  }],

  ['hex-byte-decode', sub () {
    my $buf = '';
    return sub () {
      my ($ln) = @_;
      $ln =~ s~\s|;~~sog;
      $ln =~ s~[\\&%](#?0?x|)~~sog;
      $buf .= $ln;
      while ((length $buf) > 1) {
        print chr hex substr $buf, 0, 2;
        $buf = substr $buf, 2;
      }
    }
  }],

  ['ints-to-hex-lc', [], sub () {
    $_[0] =~ s|([0-9]+)|&zerofill_even(sprintf('%02x', $1))|segr;
  }],

  ['ints-to-hex-uc', [], sub () {
    $_[0] =~ s|([0-9]+)|&zerofill_even(sprintf('%02X', $1))|segr;
  }],

  ['ints-to-hex-0x', [], sub () {
    $_[0] =~ s|([0-9]+)|'0x' . &zerofill_even(sprintf('%02X', $1))|segr;
  }],

  ['urlencode', [], sub () {
    # Even escape ":", "/", and "@", as they need to be encoded in the login
    # part of a URL (ftp://user:pass@host/).
    $_[0] =~ s|([^A-Za-z0-9_\-\.])|sprintf '%%%02X', (ord $1)|siegr;
  }],
  ['url20plus', [], sub () { $_[0] =~ s|%20|+|sgr; }],

  ['urlpathencode', [], sub () {
    # Spare some chars that have no special meaning inside the path part
    # and don't break HTML/XML.
    $_[0] =~ s|([^:A-Za-z0-9_\-=~\./!,;\&\$\@\*\(\)\[\]\{\}])|
      sprintf '%%%02X', (ord $1)|siegr;
  }],

  ['urlobfuscate', [], sub () {
    $_[0] =~ s|([^:/@\?&;=#])|sprintf '%%%02X', (ord $1)|siegr;
  }],

  ['urldecode', [], sub () {
    $_[0] =~ tr|+| |;
    $_[0] =~ s~%([0-9a-f]{2})~chr hex $1~siegr;
  }],

  ['preg_quote', [], sub () { quotemeta $_[0]; }],

  ['unescape', \&BackslashEscapesPmb::unescape],

  ['str2id', ['sepchar'], \&fac_str2id],
  ['str2id-usc',    sub () { &fac_str2id('_'); }],
  ['str2id-dash',   sub () { &fac_str2id('-'); }],
  ['str2id-camel',  sub () { &fac_str2id("\\u"); }],

  ['skip-text-in-parens', ['pairs'], sub () {
    my ($pairs) = @_;
    $pairs = &arr2hashref(split '', $pairs);
    my $open_paren_rgx = quotemeta join '', keys %{$pairs};
    return sub () {
      my ($tx) = @_;
      my $keep = '';
      my $skip;
      while ($tx =~ s~^(.*?)($open_paren_rgx)~~si) {
        $keep .= $1;
        $skip = index $tx, $pairs->{$2};
        if ($skip < 0) {
          $keep .= $2;
        } else {
          $tx = substr $tx, $skip + 1;
        }
      }
      return $keep . $tx;
    };
  }],

  ['rev-domain', [], sub () {
    return join '', reverse split m~([:/\.]+)~, $_[0];
  }],
);











return 1;
