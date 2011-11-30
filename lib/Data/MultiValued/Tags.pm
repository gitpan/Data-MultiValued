package Data::MultiValued::Tags;
{
  $Data::MultiValued::Tags::VERSION = '0.0.1_2';
}
{
  $Data::MultiValued::Tags::DIST = 'Data-MultiValued';
}
use Moose;
use MooseX::Params::Validate;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(Num Str Undef Any);
use Data::MultiValued::Exceptions;
use Data::MultiValued::TagContainer;

# ABSTRACT: Handle values with tags


has _storage => (
    is => 'rw',
    isa => class_type('Data::MultiValued::TagContainer'),
    init_arg => undef,
    lazy_build => 1,
);

sub _build__storage {
    Data::MultiValued::TagContainer->new();
}


sub set {
    my ($self,%args) = validated_hash(
        \@_,
        tag => { isa => Str, optional => 1, },
        value => { isa => Any, },
    );

    $self->_storage->get_or_create(\%args)
         ->{value} = $args{value};
}


sub get {
    my ($self,%args) = validated_hash(
        \@_,
        tag => { isa => Str, optional => 1, },
    );

    $self->_storage->get(\%args)
         ->{value};
}


sub clear {
    my ($self,%args) = validated_hash(
        \@_,
        tag => { isa => Str, optional => 1, },
    );

    $self->_storage->clear(\%args);
}


sub _rebless_storage {
    my ($self) = @_;

    bless $self->{_storage},'Data::MultiValued::TagContainer';
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

Data::MultiValued::Tags - Handle values with tags

=head1 VERSION

version 0.0.1_2

=head1 SYNOPSIS

  use Data::MultiValued::Tags;

  my $obj = Data::MultiValued::Tags->new();
  $obj->set({
    tag => 'tag1',
    value => 'a string',
  });
  say $obj->get({tag=>'tag1'}); # prints 'a string'
  say $obj->get({tag=>'tag2'}); # dies

=head1 METHODS

=head2 C<set>

  $obj->set({ tag => $the_tag, value => $the_value });

Stores the given value for the given tag. Replaces existing
values. Does not throw exceptions.

Not passing in a C<tag> is equivalent to passing in C<< tag => undef
>>.

No cloning is done: if you pass in a reference, the reference is
just stored.

=head2 C<get>

  my $value = $obj->get({ tag => $the_tag });

Retrieves the value for the given tag. Throws a
L<Data::MultiValued::Exceptions::TagNotFound|Data::MultiValued::Exceptions/Data::MultiValued::Exceptions::TagNotFound>
exception if the tag does not exists in this object.

Not passing in a C<tag> is equivalent to passing in C<< tag => undef
>>.

No cloning is done: if a reference was stored, you get it back
untouched.

=head2 C<clear>

  $obj->clear({ tag => $the_tag });

Deletes the given tag and all data associated with it. Does not throw
exceptions: if the tag does not exist, nothing happens.

Not passing in a C<tag> clears everything. Yes, this means that there
is no way to just clear the value for the C<undef> tag.

=head1 Serialisation helpers

These are used through
L<Data::MultiValued::UglySerializationHelperRole>.

=head2 C<_rebless_storage>

Blesses the storage into L<Data::MultiValued::TagContainer>.

=head2 C<_as_hash>

Returns the internal representation with no blessed hashes, with as
few copies as possible.

=head1 SEE ALSO

L<Data::MultiValued::TagContainer>, L<Data::MultiValued::Exceptions>

=head1 AUTHOR

Gianni Ceccarelli <dakkar@thenautilus.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-Porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

