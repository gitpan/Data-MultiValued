#!perl
use strict;
use warnings;
use Test::Most 'die';
use Data::Printer;
use Data::MultiValued::Tags;
use Data::MultiValued::TagsAndRanges;

sub test_it {
    my ($obj) = @_;

    lives_ok {
        $obj->set({
            tag => 'tag1',
            value => 'a string',
        });
    } 'setting tag1';
    lives_ok {
        $obj->set({
            tag => 'tag2',
            value => 'another string',
        });
    } 'setting tag2';

    cmp_ok($obj->get({tag => 'tag1'}),
           'eq',
           'a string',
           'getting tag1');

    cmp_ok($obj->get({tag => 'tag2'}),
           'eq',
           'another string',
           'getting tag2');

    dies_ok {
        $obj->get({tag=>'no such tag'});
    } 'getting non-existent tag';

    dies_ok {
        $obj->get({});
    } 'default get dies';

    $obj->clear({tag=>'tag1'});

    dies_ok {
        $obj->get({tag=>'tag1'});
    } 'getting cleared tag';

    cmp_ok($obj->get({tag => 'tag2'}),
           'eq',
           'another string',
           'getting tag2 after clearing');

    $obj->clear();

    dies_ok {
        $obj->get({tag=>'tag2'});
    } 'getting tag2 after clearing all dies';

}

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
