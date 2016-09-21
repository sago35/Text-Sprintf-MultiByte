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
    is spf("%g%3s%g", ord('A'), "あ", ord('B')), "65 あ66";
};

done_testing;

