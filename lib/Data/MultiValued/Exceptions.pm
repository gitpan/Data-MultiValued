package Data::MultiValued::Exceptions;
{
  $Data::MultiValued::Exceptions::VERSION = '0.0.1_2';
}
{
  $Data::MultiValued::Exceptions::DIST = 'Data-MultiValued';
}

# ABSTRACT: exception classes


package Data::MultiValued::Exceptions::NotFound;
{
  $Data::MultiValued::Exceptions::NotFound::VERSION = '0.0.1_2';
}
{
  $Data::MultiValued::Exceptions::NotFound::DIST = 'Data-MultiValued';
}{
use Moose;
extends 'Throwable::Error';

has value => (
    is => 'ro',
    required => 1,
);

sub as_string {
    my ($self) = @_;

    my $str = $self->message . ($self->value // '<undef>');
    $str .= "\n\n" . $self->stack_trace->as_string;

    return $str;
}
}


package Data::MultiValued::Exceptions::TagNotFound;
{
  $Data::MultiValued::Exceptions::TagNotFound::VERSION = '0.0.1_2';
}
{
  $Data::MultiValued::Exceptions::TagNotFound::DIST = 'Data-MultiValued';
}{
use Moose;
extends 'Data::MultiValued::Exceptions::NotFound';

has '+message' => (
    default => 'tag not found: ',
);
}


package Data::MultiValued::Exceptions::RangeNotFound;
{
  $Data::MultiValued::Exceptions::RangeNotFound::VERSION = '0.0.1_2';
}
{
  $Data::MultiValued::Exceptions::RangeNotFound::DIST = 'Data-MultiValued';
}{
use Moose;
extends 'Data::MultiValued::Exceptions::NotFound';

has '+message' => (
    default => 'no range found for value: ',
);
}


package Data::MultiValued::Exceptions::BadRange;
{
  $Data::MultiValued::Exceptions::BadRange::VERSION = '0.0.1_2';
}
{
  $Data::MultiValued::Exceptions::BadRange::DIST = 'Data-MultiValued';
}{
use Moose;
extends 'Throwable::Error';

has ['from','to'] => ( is => 'ro', required => 1 );
has '+message' => (
    default => 'invalid range: ',
);

sub as_string {
    my ($self) = @_;

    my $str = $self->message . $self->from . ', ' . $self->to;
    $str .= "\n\n" . $self->stack_trace->as_string;

    return $str;
}

}

1;

__END__
=pod

=head1 NAME

Data::MultiValued::Exceptions - exception classes

=head1 VERSION

version 0.0.1_2

=head1 DESCRIPTION

This module defines a few exception classes, using L<Throwable::Error>
as a base class.

=head1 CLASSES

=head2 C<Data::MultiValued::Exceptions::NotFound>

Base class for "not found" errors. Has a C<value> attribute,
containing the value that was not found.

=head2 C<Data::MultiValued::Exceptions::TagNotFound>

Subclass of L</Data::MultiValued::Exceptions::NotFound>, for
tags. Stringifies to:

  tag not found: $value

  $stack_trace

=head2 C<Data::MultiValued::Exceptions::RangeNotFound>

Subclass of L</Data::MultiValued::Exceptions::NotFound>, for
ranges. Stringifies to:

  no range found for value: $value

  $stack_trace

=head2 C<Data::MultiValued::Exceptions::BadRange>

Thrown when an invalid range is supplied to a method. An invalid range
is a range with C<from> greater than C<to>.

Stringifies to:

  invalid range: $from, $to

  $stack_trace

=head1 AUTHOR

Gianni Ceccarelli <dakkar@thenautilus.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-Porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

