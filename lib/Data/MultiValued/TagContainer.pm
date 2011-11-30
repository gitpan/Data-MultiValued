package Data::MultiValued::TagContainer;
{
  $Data::MultiValued::TagContainer::VERSION = '0.0.1_2';
}
{
  $Data::MultiValued::TagContainer::DIST = 'Data-MultiValued';
}
use Moose;
use Moose::Util::TypeConstraints;
use MooseX::Types::Moose qw(HashRef);
use Data::MultiValued::Exceptions;

# ABSTRACT: container for tagged values


has _storage => (
    is => 'rw',
    isa => HashRef,
    init_arg => undef,
    default => sub { { } },
    traits => ['Hash'],
    handles => {
        _has_tag => 'exists',
        _get_tag => 'get',
        _create_tag => 'set',
        _delete_tag => 'delete',
        all_tags => 'keys',
    },
);

has _default_tag => (
    is => 'rw',
    init_arg => undef,
    predicate => '_has_default_tag',
    clearer => '_clear_default_tag',
);


sub get {
    my ($self,$args) = @_;

    my $tag = $args->{tag};

    if (!defined($tag)) {
        if ($self->_has_default_tag) {
            return $self->_default_tag;
        }

        Data::MultiValued::Exceptions::TagNotFound->throw({
            value => $tag,
        });
    }

    if (!$self->_has_tag($tag)) {
        Data::MultiValued::Exceptions::TagNotFound->throw({
            value => $tag,
        });
    }
    return $self->_get_tag($tag);
}


sub get_or_create {
    my ($self,$args) = @_;

    my $tag = $args->{tag};

    if (!defined($tag)) {
        if ($self->_has_default_tag) {
            return $self->_default_tag;
        }
        else {
            return $self->_default_tag(
                $self->_create_new_inferior
            );
        }
    }

    if (!$self->_has_tag($tag)) {
        $self->_create_tag($tag,$self->_create_new_inferior);
    }
    return $self->_get_tag($tag);
}

sub _clear_storage {
    my ($self) = @_;

    $self->_storage({});
}


sub clear {
    my ($self,$args) = @_;

    my $tag = $args->{tag};

    if (!defined($tag)) {
        $self->_clear_default_tag;
        $self->_clear_storage;
    }
    elsif ($self->_has_tag($tag)) {
        $self->_delete_tag($tag);
    }
    return;
}


sub _create_new_inferior {
    my ($self) = @_;
    return {};
}

1;

__END__
=pod

=head1 NAME

Data::MultiValued::TagContainer - container for tagged values

=head1 VERSION

version 0.0.1_2

=head1 DESCRIPTION

Please don't use this module directly, use L<Data::MultiValued::Tags>.

This module implements the storage for tagged data. It's almost
exactly a hash, the main difference being that C<undef> is a valid key
and it's distinct from the empty string.

Another difference is that you get an exception if you try to access a
tag that's not there.

Data is kept in "storage cells", as created by
L</_create_new_inferior> (by default, a hashref).

=head1 METHODS

=head2 C<get>

  my $value = $obj->get({ tag => $the_tag });

Retrieves the "storage cell" for the given tag. Throws a
L<Data::MultiValued::Exceptions::TagNotFound|Data::MultiValued::Exceptions/Data::MultiValued::Exceptions::TagNotFound>
exception if the tag does not exists in this object.

Not passing in a C<tag> is equivalent to passing in C<< tag => undef
>>.

=head2 C<get_or_create>

  $obj->get_or_create({ tag => $the_tag });

Retrieves the "storage cell" for the given tag. If the tag does not
exist, creates a new cell (see L</_create_new_inferior>), sets it for
the tag, and returns it.

Not passing in a C<tag> is equivalent to passing in C<< tag => undef
>>.

=head2 C<clear>

  $obj->clear({ tag => $the_tag });

Deletes the given tag and all data associated with it. Does not throw
exceptions: if the tag does not exist, nothing happens.

Not passing in a C<tag>, or passing C<< tag => undef >>, clears
everything. If you want to only clear the C<undef> tag, you may call
C<_clear_default_tag> (which is considered a "protected" method).

=head2 C<all_tags>

  my @tags = $obj->all_tags;

Returns all the tags defined in this object. Does not return the
C<undef> tag.

=head2 C<_create_new_inferior>

Returns a new "storage cell", by default an empty hashref. See
L<Data::MultiValued::TagContainerForRanges> for an example of use.

=head1 AUTHOR

Gianni Ceccarelli <dakkar@thenautilus.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-Porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

