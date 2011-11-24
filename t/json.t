#!perl
use strict;
use warnings;
package Foo;{
use Moose;
use Data::MultiValued::AttributeTrait::Tags;
use Data::MultiValued::AttributeTrait::Ranges;
use Data::MultiValued::AttributeTrait::TagsAndRanges;

with 'Data::MultiValued::UglySerializationHelperRole';

has tt => (
    is => 'rw',
    isa => 'Int',
    traits => ['MultiValued::Tags'],
    default => 3,
    predicate => 'has_tt',
    clearer => 'clear_tt',
);

has rr => (
    is => 'rw',
    isa => 'Str',
    traits => ['MultiValued::Ranges'],
    predicate => 'has_rr',
    clearer => 'clear_rr',
);

has ttrr => (
    is => 'rw',
    isa => 'Str',
    default => 'default',
    traits => ['MultiValued::TagsAndRanges'],
    predicate => 'has_ttrr',
    clearer => 'clear_ttrr',
);


}
package main;
use Test::Most 'die';
use Data::Printer;
use JSON::XS;

my $opts={tag=>'something'};
my $ropts={tag=>'something',from=>10,to=>20};

my $json = JSON::XS->new->utf8;
my $obj = Foo->new(rr=>'foo');
$obj->tt_multi($opts,1234);
$obj->ttrr_multi($ropts,777);
my $hash = $obj->as_hash;
note p $hash;
my $str = $json->encode($hash);
note p $str;

note "rebuilding";
my $obj2 = Foo->new_in_place($json->decode($str));

note p $obj;
note p $obj2;

is($obj2->tt,$obj->tt,'tt');
is($obj2->tt_multi($opts),$obj->tt_multi($opts),'tt tagged');
is($obj2->ttrr_multi({at => 15}),$obj->ttrr_multi({at => 15}),'ttrr');
is($obj2->rr,$obj->rr,'rr');

done_testing;
