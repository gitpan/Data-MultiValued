#!perl
use strict;
use warnings;

package Foo;{
use Moose;
use Data::MultiValued::AttributeTrait::Ranges;

has stuff => (
    is => 'rw',
    isa => 'Int',
    traits => ['MultiValued::Ranges'],
    default => 3,
    predicate => 'has_stuff',
    clearer => 'clear_stuff',
);

has other => (
    is => 'rw',
    isa => 'Str',
    traits => ['MultiValued::Ranges'],
    predicate => 'has_other',
    clearer => 'clear_other',
);
}
package main;
use Test::Most 'die';
use Data::Printer;

subtest 'default' => sub {
    my $obj = Foo->new();

    ok(!$obj->has_other,'not has other');
    ok($obj->has_stuff,'has stuff');

    is($obj->stuff,3,'default');
};

subtest 'constructor param' => sub {
    my $obj = Foo->new({stuff=>12,other=>'bar'});

    ok($obj->has_other,'has other');
    ok($obj->has_stuff,'has stuff');

    is($obj->stuff,12,'param');
    is($obj->other,'bar','param');
};

subtest 'with ranges' => sub {
    my $obj = Foo->new();

    my $opts = {from=>10,to=>20,at=>15};

    ok($obj->has_stuff,'has stuff');
    ok($obj->has_stuff_multi($opts),'has stuff ranged (forever)');
    ok(!$obj->has_other,'not has other');
    ok(!$obj->has_other_multi($opts),'not has other ranged');

    $obj->stuff_multi($opts,7);
    $obj->other_multi($opts,'foo');

    is($obj->stuff,3,'default');
    is($obj->stuff_multi($opts),7,'stuff ranged');
    is($obj->other_multi($opts),'foo','other ranged');
};

done_testing();
