package Data::MultiValued::Ranges;
{
  $Data::MultiValued::Ranges::VERSION = '0.0.1_2';
}
{
  $Data::MultiValued::Ranges::DIST = 'Data-MultiValued';
}
use Moose;
use MooseX::Params::Validate;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(Num Str Undef Any);
use Data::MultiValued::Exceptions;
use Data::MultiValued::RangeContainer;

# ABSTRACT: Handle values with validity ranges


has _storage => (
    is => 'rw',
    isa => class_type('Data::MultiValued::RangeContainer'),
    init_arg => undef,
    lazy_build => 1,
);

sub _build__storage {
    Data::MultiValued::RangeContainer->new();
}


sub set {
    my ($self,%args) = validated_hash(
        \@_,
        from => { isa => Num|Undef, optional => 1, },
        to => { isa => Num|Undef, optional => 1, },
        value => { isa => Any, },
    );

    $self->_storage->get_or_create(\%args)
         ->{value} = $args{value};
}


sub get {
    my ($self,%args) = validated_hash(
        \@_,
        at => { isa => Num|Undef, optional => 1, },
    );

    $self->_storage->get(\%args)
         ->{value};
}


sub clear {
    my ($self,%args) = validated_hash(
        \@_,
        from => { isa => Num|Undef, optional => 1, },
        to => { isa => Num|Undef, optional => 1, },
    );

    $self->_storage->clear(\%args);
}


sub _rebless_storage {
    my ($self) = @_;

    bless $self->{_storage},'Data::MultiValued::RangeContainer';
}



sub _as_hash {
    my ($self) = @_;

    my %ret = %{$self->_storage};
    return {_storage=>\%ret};
}


1;

__END__
=pod

=head1 NAME

Data::MultiValued::Ranges - Handle values with validity ranges

=head1 VERSION

version 0.0.1_2

=head1 SYNOPSIS

  use Data::MultiValued::Ranges;

  my $obj = Data::MultiValued::Ranges->new();
  $obj->set({
    from => 10,
    to => 20,
    value => 'foo',
  });
  say $obj->get({at => 15}); # prints 'foo'
  say $obj->get({at => 35}); # dies

=head1 METHODS

=head2 C<set>

  $obj->set({ from => $min, to => $max, value => $the_value });

Stores the given value for the given range. Throws
L<Data::MultiValued::Exceptions::BadRange|Data::MultiValued::Exceptions/Data::MultiValued::Exceptions::BadRange>
if C<< $min > $max >>.

The range is defined as C<< Num $x : $min <= $x < $max >>. A C<< from
=> undef >> means "from -Inf", and a C<< to => undef >> means "to
+Inf". Not passing in C<from> or C<to> is equivalent to passing
C<undef>.

If the given range intersects existing ranges, these are spliced to
avoid overlaps. In other words:

  $obj->set({
    from => 10,
    to => 20,
    value => 'foo',
  });
  $obj->set({
    from => 15,
    to => 25,
    value => 'bar',
  });
  say $obj->get({at => 12}); # prints 'foo'
  say $obj->get({at => 15}); # prints 'bar'
  say $obj->get({at => 25}); # dies

No cloning is done: if you pass in a reference, the reference is
just stored.

=head2 C<get>

  my $value = $obj->get({ at => $point });

Retrieves the value for the given point. Throws a
L<Data::MultiValued::Exceptions::RangeNotFound|Data::MultiValued::Exceptions/Data::MultiValued::Exceptions::RangeNotFound>
exception if no ranges exist in this object that include the point
(remember that a range does not include its C<to> point).

A C<< at => undef >> means "at -Inf". Not passing in C<at> is
equivalent to passing C<undef>.

No cloning is done: if a reference was stored, you get it back
untouched.

=head2 C<clear>

  $obj->clear({ from => $min, to => $max });

Deletes all values for the given range. Throws
L<Data::MultiValued::Exceptions::BadRange|Data::MultiValued::Exceptions/Data::MultiValued::Exceptions::BadRange>
if C<< $min > $max >>.

A C<< from => undef >> means "from -Inf", and a C<< to => undef >>
means "to +Inf". Not passing in C<from> or C<to> is equivalent to
passing C<undef>. Thus, C<< $obj->clear() >> clears everything.

If the given range intersects existing ranges, these are spliced. In
other words:

  $obj->set({
    from => 10,
    to => 20,
    value => 'foo',
  });
  $obj->clear({
    from => 15,
    to => 25,
  });
  say $obj->get({at => 12}); # prints 'foo'
  say $obj->get({at => 15}); # dies

=head1 Serialisation helpers

These are used through
L<Data::MultiValued::UglySerializationHelperRole>.

=head2 C<_rebless_storage>

Blesses the storage into L<Data::MultiValued::RangeContainer>.

=head2 C<_as_hash>

Returns the internal representation with no blessed hashes, with as
few copies as possible.

=head1 SEE ALSO

L<Data::MultiValued::RangeContainer>, L<Data::MultiValued::Exceptions>

=head1 AUTHOR

Gianni Ceccarelli <dakkar@thenautilus.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-Porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

