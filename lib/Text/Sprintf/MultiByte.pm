package Text::Sprintf::MultiByte;
use 5.008001;
use strict;
use warnings;
use utf8;
use Carp;
use Encode;

our $VERSION = "0.01";

use Exporter 'import';
our @EXPORT_OK = qw(sprintf);

our $cp932 = Encode::find_encoding("cp932");

our $conversions = $] < 5.022000 ? qr/\A[cduoxefgXEGbBpn]\Z/ : qr/\A[cduoxefgXEGbBpnaA]\Z/;

sub sprintf {
    my ($fmt, @argv) = @_;
    $fmt //= "";

    my $ofs   = 0;
    my $state = "IDL";

    my $index   = 0;
    my $tmp     = "";
    my $fmt_new = "";
    my $length  = length $fmt;

    while ($ofs < $length) {
        my $s = substr $fmt, $ofs, 1;
        if ($state eq "IDL") {
            if ($s eq "%") {
                $tmp   = $s;
                $state = "READ_FORMAT";
            } else {
                $fmt_new .= $s;
            }
        } elsif ($state eq "READ_FORMAT") {
            if ($s eq "%") {
                # 'a percent sign' literal
                $fmt_new .= $tmp . $s;
                $tmp = "";
                $state = "IDL";

            } elsif ($s eq "s") {
                # %s
                $tmp .= $s;

                if ($tmp =~ /^%(([0-9]+)\$)?(-?)([0-9]+)s$/) {
                    my $x1 = $1 // "";
                    my $x2 = $2 // "";
                    my $x3 = $3 // "";
                    my $x4 = $4 // "";

                    my $pos = $x2 ne "" ? int $x2 : -1;
                    my $left = $x3 eq "-" ? 1 : 0;
                    my $width = int $x4;

                    my $tmp_index = $pos == -1 ? $index : $pos - 1;

                    my $str_width   = length $argv[$tmp_index];
                    my $cp932_width = length $cp932->encode($argv[$tmp_index]);

                    my $diff = $cp932_width - $str_width;

                    $tmp = CORE::sprintf "%%%s%s%ds", $x1, $x3, $width - $diff;
                }

                $fmt_new .= $tmp;
                $tmp = "";
                $index++;
                $state = "IDL";
            } elsif ($s =~ /$conversions/) {
                # %c, %d, %u, %o, %x, %e, %f, %g, ...
                $fmt_new .= $tmp . $s;
                $tmp = "";
                $index++;
                $state = "IDL";
            } elsif ($s eq "*") {
                $tmp .= $s;
                $state = "READ_ARGUMENT_NUMBER";
            } elsif ($s =~ /\A[0-9]\Z/) {
                $tmp .= $s;
                $state = "READ_FORMAT_OR_ARGUMENT_NUMBER";
            } elsif ($s =~ /\A[-+ #\.v]\Z/) {
                $tmp .= $s;
            } else {
                croak "not supported : $fmt";
            }
        } elsif ($state eq "READ_ARGUMENT_NUMBER") {
            if ($s =~ /\A[0-9]\Z/) {
                $tmp .= $s;
            } elsif ($s eq '$') {
                $tmp .= $s;
                $state = "READ_FORMAT";
            } else {
                $state = "READ_FORMAT";
                $index++;
                next;
            }
        } elsif ($state eq "READ_FORMAT_OR_ARGUMENT_NUMBER") {
            if ($s =~ /\A[0-9]\Z/) {
                $tmp .= $s;
            } elsif ($s eq '$') {
                $tmp .= $s;
                $state = "READ_FORMAT";
            } else {
                $state = "READ_FORMAT";
                next;
            }
        } else {
            croak "state error : $state";
        }
        $ofs++;
    }

    $fmt_new .= $tmp;

    return CORE::sprintf $fmt_new, @argv;
}

1;
__END__

=encoding utf-8

=head1 NAME

Text::Sprintf::MultiByte - sprintf with multibyte chars

=head1 SYNOPSIS

    use Text::Sprintf::MultiByte qw(sprintf);

    sprintf "<%3s>", "あ"; # multibyte char works good

=head1 DESCRIPTION

Text::Sprintf::MultiByte is sprintf with multibyte chars.

=head1 METHOD

=head2 sprintf()

sprintf() with multibyte chars.

=head1 LICENSE

Copyright (C) sago35.

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=head1 AUTHOR

sago35 E<lt>sago35@gmail.comE<gt>

=cut

