package Data::MultiValued::TagContainerForRanges;
{
  $Data::MultiValued::TagContainerForRanges::VERSION = '0.0.1_4';
}
{
  $Data::MultiValued::TagContainerForRanges::DIST = 'Data-MultiValued';
}
use Moose;
use namespace::autoclean;
use MooseX::Types::Moose qw(HashRef);
use Moose::Util::TypeConstraints;
use Data::MultiValued::RangeContainer;

# ABSTRACT: container for tagged values that are ranged containers


extends 'Data::MultiValued::TagContainer';

has '+_storage' => (
    isa => HashRef[class_type('Data::MultiValued::RangeContainer')],
);

has '+_default_tag' => (
    isa => class_type('Data::MultiValued::RangeContainer'),
);


sub _create_new_inferior {
    Data::MultiValued::RangeContainer->new();
}


sub _rebless_storage {
    my ($self) = @_;
    bless $_,'Data::MultiValued::RangeContainer'
        for values %{$self->{_storage}};
    bless $self->{_default_tag},'Data::MultiValued::RangeContainer';
    return;
}


sub _as_hash {
    my ($self) = @_;
    my %st;
    for my $k (keys %{$self->_storage}) {
        my %v = %{$self->_storage->{$k}};
        $st{$k}=\%v;
    }
    my %dt = %{$self->_default_tag};
    return {
        _storage => \%st,
        _default_tag => \%dt,
    };
}

__PACKAGE__->meta->make_immutable();

1;

__END__
=pod

=encoding utf-8

=head1 NAME

Data::MultiValued::TagContainerForRanges - container for tagged values that are ranged containers

=head1 VERSION

version 0.0.1_4

=head1 DESCRIPTION

Please don't use this module directly, use
L<Data::MultiValued::TagsAndRanges>.

This module is a subclass of L<Data::MultiValued::TagContainer>, which
only allows instances of L<Data::MultiValued::RangeContainer> as
"storage cells".

=head1 METHODS

=head2 C<_create_new_inferior>

Returns a new L<Data::MultiValued::RangeContainer> instance.

=head1 Serialisation helpers

These are used through
L<Data::MultiValued::UglySerializationHelperRole>.

=head2 C<_rebless_storage>

Blesses the "storage cells" into L<Data::MultiValued::RangeContainer>.

=head2 C<_as_hash>

Returns the internal representation with no blessed hashes, with as
few copies as possible.

=head1 AUTHOR

Gianni Ceccarelli <dakkar@thenautilus.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-Porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

