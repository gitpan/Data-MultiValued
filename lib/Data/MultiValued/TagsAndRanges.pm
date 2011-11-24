package Data::MultiValued::TagsAndRanges;
{
  $Data::MultiValued::TagsAndRanges::VERSION = '0.0.1_1';
}
{
  $Data::MultiValued::TagsAndRanges::DIST = 'Data-MultiValued';
}
use Moose;
use MooseX::Params::Validate;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(Num Str Undef Any);
use Data::MultiValued::Exceptions;
use Data::MultiValued::TagContainerForRanges;

# ABSTRACT: Handle values with tags and validity ranges


has _storage => (
    is => 'rw',
    isa => class_type('Data::MultiValued::TagContainerForRanges'),
    init_arg => undef,
    lazy_build => 1,
);

sub _build__storage {
    Data::MultiValued::TagContainerForRanges->new();
}


sub set {
    my ($self,%args) = validated_hash(
        \@_,
        from => { isa => Num|Undef, optional => 1, },
        to => { isa => Num|Undef, optional => 1, },
        tag => { isa => Str, optional => 1, },
        value => { isa => Any, },
    );

    $self->_storage->get_or_create(\%args)
         ->get_or_create(\%args)
         ->{value} = $args{value};
}


sub get {
    my ($self,%args) = validated_hash(
        \@_,
        at => { isa => Num|Undef, optional => 1, },
        tag => { isa => Str, optional => 1, },
    );

    $self->_storage->get(\%args)
         ->get(\%args)
         ->{value};
}


sub clear {
    my ($self,%args) = validated_hash(
        \@_,
        from => { isa => Num|Undef, optional => 1, },
        to => { isa => Num|Undef, optional => 1, },
        tag => { isa => Str, optional => 1, },
    );

    if (exists $args{from} || exists $args{to}) {
        $self->_storage->get(\%args)
            ->clear(\%args);
    }
    else {
        $self->_storage->clear(\%args);
    }
}


sub _rebless_storage {
    my ($self) = @_;

    bless $self->{_storage},'Data::MultiValued::TagContainerForRanges';
    $self->_storage->_rebless_storage;
}


sub _as_hash {
    my ($self) = @_;

    my $ret = $self->_storage->_as_hash;
    return {_storage=>$ret};
}

1;

__END__
=pod

=head1 NAME

Data::MultiValued::TagsAndRanges - Handle values with tags and validity ranges

=head1 VERSION

version 0.0.1_1

=head1 SYNOPSIS

  use Data::MultiValued::TagsAndRanges;

  my $obj = Data::MultiValued::TagsAndRanges->new();
  $obj->set({
    tag => 'tag1',
    from => 10,
    to => 20,
    value => 'foo',
  });
  say $obj->get({tag => 'tag1', at => 15}); # prints 'foo'
  say $obj->get({tag => 'tag1', at => 35}); # dies
  say $obj->get({tag => 'tag2', at => 15}); # dies

=head1 METHODS

=head2 C<set>

  $obj->set({ tag => $the_tag, from => $min, to => $max, value => $the_value });

Stores the given value for the given tag and range. Does not throw
exceptions.

See L<Data::MultiValued::Tags/set> and
L<Data::MultiValued::Ranges/set> for more details.

=head2 C<get>

  my $value = $obj->get({ tag => $the_tag, at => $point });

Retrieves the value for the given tag and point. Throws a
L<Data::MultiValued::Exceptions::RangeNotFound> exception if no ranges
exist in this object that include the point, and
L<Data::MultiValued::Exceptions::TagNotFound> exception if the tag
does not exists in this object.

See L<Data::MultiValued::Tags/get> and
L<Data::MultiValued::Ranges/get> for more details.

=head2 C<clear>

  $obj->clear({ tag => $the_tag, from => $min, to => $max });

If a range is specified, deletes all values for the given range and
tag. If no range is specified, delete all values for the given tag.

Does not throw exceptions.

See L<Data::MultiValued::Tags/clear> and
L<Data::MultiValued::Ranges/clear> for more details.

=head1 Serialisation helpers

These are used through
L<Data::MultiValued::UglySerializationHelperRole>.

=head2 C<_rebless_storage>

Blesses the storage into L<Data::MultiValued::TagContainerForRanges>,
then calls C<_rebless_storage> on it.

=head2 C<_as_hash>

Returns the internal representation with no blessed hashes, with as
few copies as possible. Depends on
L<Data::MultiValued::TagContainerForRanges/_as_hash>.

=head1 AUTHOR

Gianni Ceccarelli <dakkar@thenautilus.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

