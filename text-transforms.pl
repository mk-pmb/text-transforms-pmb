#!/usr/bin/perl
# -*- coding: UTF-8, tab-width: 2 -*-

use strict;
use warnings;

my @tr_groups = (
  'bins',
  'misc',
  );

binmode STDIN;
binmode STDOUT;
$| = 1;  # disable output buffering (tribute to perl 5.8.x)

use FindBin;
use lib "$FindBin::RealBin/lib/perl/";
use BackslashEscapesPmb;

my $known_transforms = {};
my $known_cli_defaults = {
  ':cli-space' => ['--add-default-space', '-N'],
};

sub l8r () { my ($x) = @_; return sub () { return $x; }; }
sub arr2ref () { return \@_; }
sub arr2hashref () { my %hash = @_; return \%hash; }


sub tr_main () {
  my @cli_args = @_;

  if ((@cli_args > 0) and ($cli_args[0] eq '--help')) {
    print 'H: available transforms: ', join(' ', sort keys %{&reg_tr()}), "\n";
    exit 0;
  }

  my ($args, $selected_transforms, $opts) = &tr_parse_cli(@cli_args);

  if (defined $opts->{'raw-hello'}) { print $opts->{'raw-hello'}; }

  my $arg_iter = (@{$args} > 0
    ? sub () { return shift @{$args}; }
    : sub () { return scalar <STDIN>; });

  my ($buf, $transform_subref);
  while (defined($buf = &$arg_iter())) {
    foreach $transform_subref (@{$selected_transforms}) {
      # &expect_ref_type('CODE', $transform_subref, 'tr_subref', 'tr_main');
      # &expect_ref_type('', $buf, 'buf (in)', 'tr_main');
      $buf = &$transform_subref($buf, $opts);
      # &expect_ref_type('', $buf, 'buf (out)', 'tr_main');
    }
    if (defined $buf) { print $buf; }
  }

  if (defined $opts->{'raw-goodbye'}) { print $opts->{'raw-goodbye'}; }
  return 0;
}


sub tr_parse_cli() {
  my $args_ref = \@_;
  my $selected_transforms = [];
  my $opts = {};
  (my $invocation = $FindBin::Script) =~ s~\.pl$~~;
  my $add_factory = sub () {
    my $facname = shift;
    my $factory = &reg_tr($facname);
    if (ref($factory) eq 'CODE') {
      push @{$selected_transforms}, &$factory($args_ref);
      return 1;
    }
    return 0;
  };
  unless (&$add_factory($invocation)) { $invocation = ''; }
  my $narg = sub () { return shift @{$args_ref}; };
  my $parse_args = sub () {
    while (@{$args_ref} > 0) {
      my $arg = &$narg();
      if ($arg eq '--') { last; }

      if ($arg eq '-n') { $arg = '--add-lf'; }
      if ($arg eq '--raw-hello') { $opts->{'raw-hello'} = &$narg(); next; }
      if ($arg eq '--raw-goodbye') { $opts->{'raw-goodbye'} = &$narg(); next; }
      if ($arg eq '-N') { $opts->{'raw-goodbye'} = "\n"; next; }

      if ("$arg" =~ m/^--(\S+)$/) {
        $arg = $1;
        if (&$add_factory($1)) { next; }
        die "E: Unsupported long option: '--$arg'";
      }
      if ("$arg" =~ m/^-/) {
        die "E: Unsupported short option: '$arg'";
      }

      # assume non-option to be input:
      unshift @{$args_ref}, $arg;
      last;
    }
  };
  &$parse_args();
  unless (@{$selected_transforms} > 0) {
    die "E: no transforms selected! Maybe --identity is what you want?";
  }
  if (($invocation ne '') and (@{$selected_transforms} == 1)) {
    my $default_opts = $known_cli_defaults->{$invocation};
    my $dflt_opts_type = ref $default_opts;
    my @extra_opts = ();
    if (defined $default_opts) {
      if ($dflt_opts_type eq '') {
        if (defined $known_cli_defaults->{$default_opts}) {
          $default_opts = $known_cli_defaults->{$default_opts};
          $dflt_opts_type = ref $default_opts;
        }
      }
      if ($dflt_opts_type eq 'ARRAY') {
        push @extra_opts, @{$default_opts};
      } elsif ($dflt_opts_type eq 'CODE') {
        push @extra_opts, &$default_opts($args_ref, $selected_transforms);
      } else {
        die "E: unsupported type ($dflt_opts_type) of default CLI options." .
          " (invoked as '$invocation', opts: '$default_opts')";
      }
      # warn "default opts: ($dflt_opts_type) $default_opts";
    }
    if (@extra_opts > 0) {
      unshift @{$args_ref}, @extra_opts, '--';
      &$parse_args();
    }
  }
  $opts->{'cli_input_argc'} = @{$args_ref};
  return ($args_ref, $selected_transforms, $opts);
}


sub ifnull_str () {
  foreach my $val (@_) {
    next unless defined $val;
    return $val unless $val eq '';
  }
  return '';
}


sub expect_ref_type () {
  my ($expected_type, $val, $varname, $where) = @_;
  my $actual_type = ref $val;
  if ($actual_type eq $expected_type) { return 1; }
  my $err = "E: expected ref type '$expected_type', not '$actual_type'";
  $err .= " for $varname" unless $varname eq '';
  $err .= " in $where" unless $where eq '';
  $err .= ". data: '$val'";
  die $err;
}


sub shift_trans_args () {
  my ($tr_name, $args_ref, @arg_names) = @_;
  my ($tr_fac, $arg_name, $arg_val, @arg_vals, @arg_miss);
  foreach $arg_name (@arg_names) {
    $arg_val = shift @{$args_ref};
    if (defined $arg_val) {
      push @arg_vals, $arg_val;
    } else {
      push @arg_miss, $arg_name;
    }
  }
  if (@arg_miss > 0) {
    die join ' ', "$tr_name: missing argument(s):" , @arg_miss;
  }
  return @arg_vals;
}


sub genfac_trans_args () {
  my ($tr_name, $tr_fac, @arg_names) = @_;

  if ($tr_name eq 'shell-quotex') {
    $tr_fac = &l8r($tr_fac);
    warn "genfac_trans_args($tr_name): $tr_fac";
    return $tr_fac;
  }
  if (@arg_names == 0) { return &l8r($tr_fac); }
  return sub {
    my ($args_ref) = @_;
    return &$tr_fac(&shift_trans_args($tr_name, $args_ref, @arg_names));
  };
}


sub reg_tr () {
  unless (@_ > 0) { return $known_transforms; }
  my $tr_name = shift;
  if (ref($tr_name) eq 'ARRAY') {
    return map { &reg_tr(@{$_}) } ($tr_name, @_);
  }
  unless (@_ > 0) { return $known_transforms->{$tr_name}; }

  if (defined $known_transforms->{$tr_name}) {
    die "reg_tr($tr_name): duplicate definition";
  }

  my ($arg_names, $tr_fac, $cli_defaults) = @_;
  if (not defined $arg_names) {
    $arg_names = 'no factory? args(' . scalar(@_) . '):';
    map { $arg_names .= " <$_>"; } @_;
    die "reg_tr($tr_name): $arg_names";
  } elsif (ref($arg_names) eq 'ARRAY') {
    $tr_fac = &genfac_trans_args($tr_name, $tr_fac, @{$arg_names});
  } elsif (ref($arg_names) eq 'CODE') {
    # $tr_fac will handle the $args_ref.
    ($tr_fac, $cli_defaults) = @_;
    $arg_names = undef;
  } else {
    $tr_fac .= " (args: $arg_names)";
    die "reg_tr($tr_name): factory is not a CODE ref: $tr_fac";
  }

  if (defined $cli_defaults) {
    $known_cli_defaults->{$tr_name} = $cli_defaults;
  }

  $known_transforms->{$tr_name} = $tr_fac;
  return $tr_fac;
}

















map { require "$FindBin::RealBin/txtr.$_.pl"; } @tr_groups;
exit &tr_main(@ARGV);
