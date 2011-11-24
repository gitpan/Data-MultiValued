#!perl
use strict;
use warnings;
use Test::Most 'die';
use Data::Printer;
use Data::MultiValued::Ranges;
use Data::MultiValued::Tags;
use Data::MultiValued::TagsAndRanges;

sub test_it {
    my ($obj) = @_;

    lives_ok {
        $obj->set({
            value => 1234,
        });
    } 'setting';

    cmp_ok($obj->get({}),'==',1234,
           'getting');

    lives_ok { $obj->clear } 'clearing the object';
}

subtest 'ranges' => sub {
    my $obj = Data::MultiValued::Ranges->new();
    ok($obj,'constructor works');

    test_it($obj);
};

subtest 'tags' => sub {
    my $obj = Data::MultiValued::Tags->new();
    ok($obj,'constructor works');

    test_it($obj);
};

subtest 'tags and ranges' => sub {
    my $obj = Data::MultiValued::TagsAndRanges->new();
    ok($obj,'constructor works');

    test_it($obj);
};

done_testing();
