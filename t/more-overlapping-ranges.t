#!perl
use strict;
use warnings;
use Test::Most 'die';
use Data::Printer;
use Data::MultiValued::Ranges;
use Data::MultiValued::TagsAndRanges;

sub test_it {
    my ($obj) = @_;

    $obj->set({
        from=>10,
        to=>20,
        value=>1,
    });
    $obj->set({
        from=>30,
        to => 50,
        value => 2,
    });
    $obj->set({
        from=>15,
        to => 35,
        value => 3,
    });
    $obj->set({
        from => undef,
        to => 12,
        value => 4,
    });
    $obj->set({
        from => 40,
        to => undef,
        value => 5,
    });

    my %points = (
        1,4,
        9,4,
        10,4,
        11,4,
        12,1,
        13,1,
        14,1,
        15,3,
        19,3,
        20,3,
        30,3,
        34,3,
        35,2,
        39,2,
        40,5,
        50,5,
        200,5,
    );
    while (my ($at,$v) = each %points) {
        cmp_ok($obj->get({at=>$at}),
               '==',
               $v,
               "value at $at");
    }
}

subtest 'ranges' => sub {
    my $obj = Data::MultiValued::Ranges->new();
    ok($obj,'constructor works');

    test_it($obj);
};

subtest 'tags and ranges' => sub {
    my $obj = Data::MultiValued::TagsAndRanges->new();
    ok($obj,'constructor works');

    test_it($obj);
};

done_testing();
