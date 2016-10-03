use strict;
use warnings;
use utf8;
use Test::More;
use Text::Sprintf::Zenkaku qw(sprintf);
use Test::Trap;
use Test::Exception;

use Term::Encoding qw(term_encoding);
eval {
    my $encoding = term_encoding;
    binmode STDOUT => "encoding($encoding)";
    binmode STDERR => "encoding($encoding)";
};

subtest "complex width pattern" => sub {
    is sprintf('[%*3$s][%*3$s]', 'あ', 'いう', 6), '[    あ][  いう]';
};

done_testing;

