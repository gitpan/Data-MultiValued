package Data::MultiValued::Exceptions;
{
  $Data::MultiValued::Exceptions::VERSION = '0.0.1_1';
}
{
  $Data::MultiValued::Exceptions::DIST = 'Data-MultiValued';
}
package Data::MultiValued::Exceptions::NotFound;
{
  $Data::MultiValued::Exceptions::NotFound::VERSION = '0.0.1_1';
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
  $Data::MultiValued::Exceptions::TagNotFound::VERSION = '0.0.1_1';
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
  $Data::MultiValued::Exceptions::RangeNotFound::VERSION = '0.0.1_1';
}
{
  $Data::MultiValued::Exceptions::RangeNotFound::DIST = 'Data-MultiValued';
}{
use Moose;
extends 'Data::MultiValued::Exceptions::NotFound';

has '+message' => (
    default => 'no range found for value ',
);
}
package Data::MultiValued::Exceptions::BadRange;
{
  $Data::MultiValued::Exceptions::BadRange::VERSION = '0.0.1_1';
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

Data::MultiValued::Exceptions

=head1 VERSION

version 0.0.1_1

=head1 AUTHOR

Gianni Ceccarelli <dakkar@thenautilus.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

