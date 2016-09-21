package Text::Sprintf::MultiByte;
use 5.008001;
use strict;
use warnings;
use utf8;
use Carp;
use Encode;

our $VERSION = "0.01";

use Exporter 'import';
our @EXPORT = qw(spf);

our $cp932 = Encode::find_encoding("cp932");

sub spf {
    my ($fmt, @argv) = @_;
    $fmt //= "";

    my $ofs   = 0;
    my $state = "IDL";

    my $index   = 0;
    my $tmp     = "";
    my $fmt_new = "";
    my $length  = length $fmt;

    while ($ofs <= $length) {
        my $s = substr $fmt, $ofs, 1;
        if ($state eq "IDL") {
            if ($s eq "%") {
                if ($ofs + 1 <= $length) {
                    $tmp   = $s;
                    $state = "READ_FORMAT";
                } else {
                    $fmt_new = $s;
                }
            } else {
                $fmt_new .= $s;
            }
        } elsif ($state eq "READ_FORMAT") {
            if ($s eq "%") {
                # 'a percent sign' literal
                $fmt_new .= "%%";
                $state = "IDL";

            } elsif ($s eq "s") {
                # %s
                $tmp .= $s;

                if ($tmp =~ /^%(-?)([0-9]+)s$/) {
                    my $left = $1 eq "-" ? 1 : 0;
                    my $width = int $2;

                    my $str_width   = length $argv[$index];
                    my $cp932_width = length $cp932->encode($argv[$index]);

                    my $diff = $cp932_width - $str_width;

                    $tmp = sprintf "%%%s%ds", $1, $width - $diff;
                }

                $fmt_new .= $tmp;
                $index++;
                $state = "IDL";
            } elsif ($s eq "c") {
                # %c
                $fmt_new .= $tmp . $s;
                $index++;
                $state = "IDL";
            } elsif ($s eq "-") {
                $tmp .= $s;
            } elsif ($s =~ /[0-9]/) {
                $tmp .= $s;
            } else {
                croak "not supported : $fmt";
            }
        } else {
            croak "state error : $state";
        }
        $ofs++;
    }

    return sprintf $fmt_new, @argv;
}

1;
__END__

=encoding utf-8

=head1 NAME

Text::Sprintf::MultiByte - It's new $module

=head1 SYNOPSIS

    use Text::Sprintf::MultiByte;

=head1 DESCRIPTION

Text::Sprintf::MultiByte is ...

=head1 LICENSE

Copyright (C) sago35.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

sago35 E<lt>sago35@gmail.comE<gt>

=cut

