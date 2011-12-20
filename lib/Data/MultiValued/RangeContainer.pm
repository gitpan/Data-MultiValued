package Data::MultiValued::RangeContainer;
{
  $Data::MultiValued::RangeContainer::VERSION = '0.0.1_4';
}
{
  $Data::MultiValued::RangeContainer::DIST = 'Data-MultiValued';
}
use Moose;
use namespace::autoclean;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(Num Str Any Undef ArrayRef);
use MooseX::Types::Structured qw(Dict);
use Data::MultiValued::Exceptions;

# ABSTRACT: container for ranged values


has _storage => (
    is => 'rw',
    isa => ArrayRef[
        Dict[
            from => Num|Undef,
            to => Num|Undef,
            value => Any,
        ],
    ],
    init_arg => undef,
    default => sub { [ ]  },
);


sub get {
    my ($self,$args) = @_;

    my $at = $args->{at};

    my ($range) = $self->_get_slot_at($at);

    if (!$range) {
        Data::MultiValued::Exceptions::RangeNotFound->throw({
            value => $at,
        });
    }

    return $range;
}

# Num|Undef,Num|Undef,Bool,Bool
# the bools mean "treat the undef as +inf" (-inf when omitted/false)
sub _cmp {
    my ($a,$b,$sa,$sb) = @_;

    $a //= $sa ? 0+'inf' : 0-'inf';
    $b //= $sb ? 0+'inf' : 0-'inf';

    return $a <=> $b;
}

# a binary search would be a good idea.

sub _get_slot_at {
    my ($self,$at) = @_;

    for my $slot (@{$self->_storage}) {
        next if _cmp($slot->{to},$at,1,0) <= 0;
        last if _cmp($slot->{from},$at,0,0) > 0;
        return $slot;
    }
    return;
}

# this is quite probably uselessly slow: we don't really need all of
# @before and @after, we just need to know if they're not empty; also,
# a binary search would be a good idea.

sub _partition_slots {
    my ($self,$from,$to) = @_;

    my (@before,@overlap,@after);
    my $st=$self->_storage;

    for my $idx (0..$#$st) {
        my $slot = $st->[$idx];

        my ($sf,$st) = @$slot{'from','to'};

        if (_cmp($st,$from,1,0) <0) {
            push @before,$idx;
        }
        elsif (_cmp($sf,$to,0,1) >=0) {
            push @after,$idx;
        }
        else {
            push @overlap,$idx;
        }
    }
    return \@before,\@overlap,\@after;
}


sub get_or_create {
    my ($self,$args) = @_;

    my $from = $args->{from};
    my $to = $args->{to};

    Data::MultiValued::Exceptions::BadRange->throw({
        from => $from,
        to => $to,
    }) if _cmp($from,$to,0,1)>0;

    my ($range) = $self->_get_slot_at($from);

    if ($range
        && _cmp($range->{from},$from,0,0)==0
        && _cmp($range->{to},$to,1,1)==0) {
        return $range;
    }

    $range = $self->_create_slot($from,$to);
    return $range;
}


sub clear {
    my ($self,$args) = @_;

    my $from = $args->{from};
    my $to = $args->{to};

    Data::MultiValued::Exceptions::BadRange->throw({
        from => $from,
        to => $to,
    }) if _cmp($from,$to,0,1)>0;

    return $self->_clear_slot($from,$to);
}

sub _create_slot {
    my ($self,$from,$to) = @_;

    $self->_splice_slot($from,$to,{
        from => $from,
        to => $to,
        value => undef,
    });
}

sub _clear_slot {
    my ($self,$from,$to) = @_;

    $self->_splice_slot($from,$to);
}

# Most of the splicing mechanics is here. Given a range and something
# to put in it, do "the right thing"

sub _splice_slot {
    my ($self,$from,$to,$new) = @_;

    # if !$new, it's like C<splice> without a replacement list: we
    # just delete the range

    if (!@{$self->_storage}) { # empty, just store
        push @{$self->_storage},$new if $new;
        return $new;
    }

    my ($before,$overlap,$after) = $self->_partition_slots($from,$to);

    if (!@$before && !@$overlap) {
        # nothing before, nothing overlapping: put $new at the beginning
        unshift @{$self->_storage},$new if $new;
        return $new;
    }
    if (!@$after && !@$overlap) {
        # nothing after, nothing overlapping: put $new at the end
        push @{$self->_storage},$new if $new;
        return $new;
    }

    # ok, we have to insert in the middle of things, and maybe we have
    # to trim existing ranges

    my $first_to_replace;
    my $how_many = @$overlap;

    my @replacement = $new ? ($new) : ();

    if ($how_many > 0) { # we have to splice
        # by costruction, the first and the last may have to be split, all
        # others must be removed
        $first_to_replace = $overlap->[0];
        my $last_to_replace = $overlap->[-1];
        my $first = $self->_storage->[$first_to_replace];
        my $last = $self->_storage->[$last_to_replace];

        # does the first overlapping range need trimming?
        if (_cmp($first->{from},$from,0,0)<0
            && _cmp($first->{to},$from,1,0)>=0) {
            unshift @replacement, {
                from => $first->{from},
                to => $from,
                value => $first->{value},
            }
        }
        # does the last overlapping range need trimming?
        if (_cmp($last->{from},$to,0,1)<=0
            && _cmp($last->{to},$to,1,1)>0) {
            push @replacement, {
                from => $to,
                to => $last->{to},
                value => $last->{value},
            }
        }
    }
    else {
        # no overlaps, just insert between @before and @after
        $first_to_replace = $before->[-1]+1;
    }

    splice @{$self->_storage},
           $first_to_replace,$how_many,
           @replacement;

    return $new;
}


sub all_ranges {
    my ($self) = @_;

    return map { [ $_->{from}, $_->{to} ] } @{$self->_storage};
}

__PACKAGE__->meta->make_immutable();

1;

__END__
=pod

=encoding utf-8

=head1 NAME

Data::MultiValued::RangeContainer - container for ranged values

=head1 VERSION

version 0.0.1_4

=head1 DESCRIPTION

Please don't use this module directly, use L<Data::MultiValued::Ranges>.

This module implements the storage for ranged data. It's similar to
L<Array::IntSpan>, but simpler (and slower).

A range is defined by a pair of numbers, C<from> and C<to>, and it
contains C<< Num $x : $min <= $x < $max >>. C<undef> is treated as
"inf" (negative infinity if used as C<from> or C<at>, positive
infinity if used as C<to>).

The internal representation of a range is a hash with three keys,
C<from> C<to> C<value>.

=head1 METHODS

=head2 C<get>

  my $value = $obj->get({ at => $point });

Retrieves the range that includes the given point. Throws a
L<Data::MultiValued::Exceptions::RangeNotFound|Data::MultiValued::Exceptions/Data::MultiValued::Exceptions::RangeNotFound>
exception if no range includes the point.

=head2 C<get_or_create>

  $obj->get_or_create({ from => $min, to => $max });

Retrieves the range that has the given extremes. If no such range
exists, creates a new range, splicing any existing overlapping range,
and returns it. Throws
L<Data::MultiValued::Exceptions::BadRange|Data::MultiValued::Exceptions/Data::MultiValued::Exceptions::BadRange>
if C<< $min > $max >>.

=head2 C<clear>

  $obj->clear({ from => $min, to => $max });

Removes the range that has the given extremes. If no such range
exists, splices any existing overlapping range so that C<<
$obj->get({at => $point }) >> for any C<< $min <= $point < $max >>
will die.

Throws
L<Data::MultiValued::Exceptions::BadRange|Data::MultiValued::Exceptions/Data::MultiValued::Exceptions::BadRange>
if C<< $min > $max >>.

=head2 C<all_ranges>

  my @ranges = $obj->all_ranges;

Returns all the ranges defined in this object, as a list of 2-elements
arrayrefs.

=head1 AUTHOR

Gianni Ceccarelli <dakkar@thenautilus.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-Porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

