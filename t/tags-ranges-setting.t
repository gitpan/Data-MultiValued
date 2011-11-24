#!perl
use strict;
use warnings;
use Test::Most 'die';
use Data::Printer;
use Data::MultiValued::TagsAndRanges;

my $obj = Data::MultiValued::TagsAndRanges->new();
ok($obj,'constructor works');

my @tags = (undef,'tag1','tag2');
my @ranges = ([10,20,2],[30,50,2]);

sub _t { $_[0] ? ( tag => $_[0] ) : () }

for my $tag (@tags) {
    for my $range (@ranges) {
        $obj->set({
            _t($tag),
            from => $range->[0],
            to => $range->[1],
            value => $range->[2],
        });
    }
}

for my $tag (@tags) {
    for my $range (@ranges) {
        cmp_ok(
            $obj->get({
                _t($tag),
                at => ($range->[0]+$range->[1])/2,
            }),
            '==',
            $range->[2],
            "tag @{[ $tag // 'default' ]}, range @$range[0,1]",
        );
    }
}

for my $range (@ranges) {
    dies_ok {
        $obj->get({
            tag => 'not there',
            from => $range->[0],
            to => $range->[1],
        })
    } "no such tag, range @$range[0,1]";
}

for my $tag (@tags) {
    for my $range (@ranges) {
        dies_ok {
            $obj->get({
                _t($tag),
                at => $range->[0]-1,
            })
        } "tag @{[ $tag // 'default' ]}, out-of-range (left)";
        dies_ok {
            $obj->get({
                _t($tag),
                at => $range->[1],
            })
        } "tag @{[ $tag // 'default' ]}, out-of-range (right)";
    }
}

$obj->clear({tag=>$tags[1],from=>$ranges[0]->[0],to=>$ranges[0]->[1]});
dies_ok {
    $obj->get({
        tag=>$tags[1],
        at => $ranges[0]->[0]+1,
    })
} 'getting deleted range from inside tag dies';

cmp_ok(
    $obj->get({
        tag => $tags[1],
        at => $ranges[1]->[0]+1,
    }),
    '==',
    $ranges[1]->[2],
    'other ranges in same tag are still there');

done_testing();
