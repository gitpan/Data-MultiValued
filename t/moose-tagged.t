#!perl
use strict;
use warnings;

package Foo;{
use Moose;
use Data::MultiValued::AttributeTrait::Tags;

has stuff => (
    is => 'rw',
    isa => 'Int',
    traits => ['MultiValued::Tags'],
    default => 3,
    predicate => 'has_stuff',
    clearer => 'clear_stuff',
    multi_accessor => 'stuff_tagged',
    multi_predicate => 'has_stuff_tagged',
);

has other => (
    is => 'rw',
    isa => 'Str',
    traits => ['MultiValued::Tags'],
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

subtest 'with tags' => sub {
    my $obj = Foo->new();

    my $opts = {tag=>'one'};

    ok($obj->has_stuff,'has stuff');
    ok(!$obj->has_stuff_tagged($opts),'not has stuff tagged');
    ok(!$obj->has_other,'not has other');
    ok(!$obj->has_other_multi($opts),'not has other tagged');

    $obj->stuff_tagged($opts,7);
    $obj->other_multi($opts,'foo');

    is($obj->stuff,3,'default');
    is($obj->stuff_tagged($opts),7,'stuff tagged');
    is($obj->other_multi($opts),'foo','other tagged');
};

done_testing();
