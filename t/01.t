use strict;
use warnings;
use utf8;
use Test::More;
use Text::Sprintf::MultiByte;

use Term::Encoding qw(term_encoding);
my $encoding = term_encoding;
binmode STDOUT => "encoding($encoding)";
binmode STDERR => "encoding($encoding)";
# テスト

subtest "normal" => sub {
    is spf(), "";
    is spf("hello"), "hello";
    is spf("hello %s", "world"), "hello world";
};

subtest "format %s" => sub {
    is spf("[%s]",   "hello"), "[hello]";
    is spf("[%6s]",  "hello"), "[ hello]";
    is spf("[%-6s]", "hello"), "[hello ]";
};

subtest "format %s with multibyte" => sub {
    is spf("[%s]",   "A"), "[A]";
    is spf("[%6s]",  "A"), "[     A]";
    is spf("[%-6s]", "A"), "[A     ]";

    is spf("[%s]",   "あ"), "[あ]";
    is spf("[%6s]",  "あ"), "[    あ]";
    is spf("[%-6s]", "あ"), "[あ    ]";
};

subtest "format %s with multibyte 2" => sub {
    is spf("[%-12s]", "hello 世界."), "[hello 世界. ]";
    is spf("[%-11s]", "hello 世界."), "[hello 世界.]";
    is spf("[%-10s]", "hello 世界."), "[hello 世界.]";

    is spf("[%12s]", "hello 世界."), "[ hello 世界.]";
    is spf("[%11s]", "hello 世界."), "[hello 世界.]";
    is spf("[%10s]", "hello 世界."), "[hello 世界.]";

    is spf("[%-20s][%1s][%-1s]", "hello 世界.", "あ", "い"), "[hello 世界.         ][あ][い]";
};

subtest "spf with no parentheses" => sub {
    is + (spf "[%-12s]", "hello 世界."), "[hello 世界. ]";
    is + (spf "[%-11s]", "hello 世界."), "[hello 世界.]";
    is + (spf "[%-10s]", "hello 世界."), "[hello 世界.]";

    is + (spf "[%12s]", "hello 世界."), "[ hello 世界.]";
    is + (spf "[%11s]", "hello 世界."), "[hello 世界.]";
    is + (spf "[%10s]", "hello 世界."), "[hello 世界.]";

    is + (spf "[%-20s][%1s][%-1s]", "hello 世界.", "あ", "い"), "[hello 世界.         ][あ][い]";
};

subtest "spf with no parentheses" => sub {
    is + (spf), "";
    is + (spf "[%-12s]", "hello 世界."), "[hello 世界. ]";
    is + (spf "[%-11s]", "hello 世界."), "[hello 世界.]";
    is + (spf "[%-10s]", "hello 世界."), "[hello 世界.]";

    is + (spf "[%12s]", "hello 世界."), "[ hello 世界.]";
    is + (spf "[%11s]", "hello 世界."), "[hello 世界.]";
    is + (spf "[%10s]", "hello 世界."), "[hello 世界.]";

    is + (spf "[%-20s][%1s][%-1s]", "hello 世界.", "あ", "い"), "[hello 世界.         ][あ][い]";
};

subtest "spf %%" => sub {
    is spf("%%%%%s%%", "あ"), "%%あ%";
};

subtest "spf %c" => sub {
    is spf("%c%3s%c", ord('A'), "あ", ord('B')), "A あB";
};

subtest "spf %d" => sub {
    is spf("%d%3s%d", ord('A'), "あ", ord('B')), "65 あ66";
};

subtest "spf %u" => sub {
    is spf("%u%3s%u", ord('A'), "あ", ord('B')), "65 あ66";
};

subtest "spf %o" => sub {
    is spf("%o%3s%o", ord('A'), "あ", ord('B')), "101 あ102";
};

subtest "spf %x" => sub {
    is spf("%x%3s%x", ord('A'), "あ", ord('B')), "41 あ42";
};

subtest "spf %e" => sub {
    is spf("%e%3s%e", ord('A'), "あ", ord('B')), "6.500000e+001 あ6.600000e+001";
};

subtest "spf %f" => sub {
    is spf("%f%3s%f", ord('A'), "あ", ord('B')), "65.000000 あ66.000000";
};

subtest "spf %g" => sub {
    is spf("%g%3s%g", ord('A'), "あ", 6.6e-9), "65 あ6.6e-009";
};

subtest "spf %X" => sub {
    is spf("%X%3s%X", ord('A'), "あ", 0xFF), "41 あFF";
};

subtest "spf %E" => sub {
    is spf("%E%3s%E", ord('A'), "あ", ord('B')), "6.500000E+001 あ6.600000E+001";
};

subtest "spf %G" => sub {
    is spf("%G%3s%G", ord('A'), "あ", 6.6e-9), "65 あ6.6E-009";
};

subtest "spf %b" => sub {
    is spf("%b%3s%b", ord('A'), "あ", ord('B')), "1000001 あ1000010";
};

subtest "spf %B" => sub {
    is spf("%B%3s%B", ord('A'), "あ", ord('B')), "1000001 あ1000010";
};

subtest "spf %p" => sub {
    my $x = ord('A');
    my $y = ord('B');
    like spf("%p%3s%p", \$x, "あ", \$y), qr/^[0-9a-f]{4,} あ[0-9a-f]{4,}$/;
};

subtest "spf %n" => sub {
    ok 1;
};

subtest "spf %a" => sub {
    is spf("%a%3s%a", ord('A'), "あ", ord('B')), "0x1.04p+6 あ0x1.08p+6";
};

subtest "spf %A" => sub {
    is spf("%A%3s%A", ord('A'), "あ", ord('B')), "0X1.04P+6 あ0X1.08P+6";
};

done_testing;

