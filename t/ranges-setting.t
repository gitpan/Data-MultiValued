#!perl
use strict;
use warnings;
use Test::Most 'die';
use Data::Printer;
use Data::MultiValued::Ranges;
use Data::MultiValued::TagsAndRanges;

sub test_it {
    my ($obj) = @_;

    lives_ok {
        $obj->set({
            from => 10,
            to => 20,
            value => [1,2,3],
        });
    } 'setting 10-20';
    lives_ok {
        $obj->set({
            from => 30,
            to => 50,
            value => [4,5,6],
        });
    } 'setting 30-50';

    lives_ok {
        $obj->set({
            from => 25,
            to => 27,
            value => [7,8,9],
        });
    } 'setting 30-50';

    cmp_deeply($obj->get({at => 15}),
               [1,2,3],
               'getting 15');
    cmp_deeply($obj->get({at => 10}),
               [1,2,3],
               'getting 10');
    cmp_deeply($obj->get({at => 19.999}),
               [1,2,3],
               'getting 19.999');
    dies_ok {
        $obj->get({at => 20})
    } 'getting 20 dies';

    cmp_deeply($obj->get({at => 40}),
               [4,5,6],
               'getting 40');
    cmp_deeply($obj->get({at => 30}),
               [4,5,6],
               'getting 30');
    cmp_deeply($obj->get({at => 49.999}),
               [4,5,6],
               'getting 49.999');
    dies_ok {
        $obj->get({at => 50})
    } 'getting 50 dies';

    cmp_deeply($obj->get({at => 25}),
               [7,8,9],
               'getting 25');

    dies_ok {
        $obj->get({at => 0})
    } 'getting 0 dies';

    dies_ok {
        $obj->get({});
    } 'default get dies';

    $obj->clear({from=>10,to=>20});

    dies_ok {
        $obj->get({at => 15})
    } 'getting 15 after clearing dies';

    cmp_deeply($obj->get({at => 30}),
               [4,5,6],
               'getting 30 after clearing');

    $obj->clear();

    dies_ok {
        $obj->get({at => 30})
    } 'getting 30 after clearing all dies';

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
