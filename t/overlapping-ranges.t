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
        from=>15,
        to => 30,
        value => 2,
    });

    my %points = (
        10,1,
        12,1,
        13,1,
        14,1,
        15,2,
        17,2,
        19,2,
        20,2,
        25,2,
        29,2,
    );
    while (my ($at,$v) = each %points) {
        cmp_ok($obj->get({at=>$at}),
               '==',
               $v,
               "value at $at");
    }

    dies_ok {
        $obj->get({at=>30})
    } 'far end';
    dies_ok {
        $obj->get({at=>9})
    } 'far end';
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
