package Data::MultiValued::AttributeTrait::Ranges;
{
  $Data::MultiValued::AttributeTrait::Ranges::VERSION = '0.0.1_1';
}
{
  $Data::MultiValued::AttributeTrait::Ranges::DIST = 'Data-MultiValued';
}
use Moose::Role;
use Data::MultiValued::Ranges;
with 'Data::MultiValued::AttributeTrait';

# ABSTRACT: attribute traits for attributes holding ranged values


sub multivalue_storage_class { 'Data::MultiValued::Ranges' };
sub opts_to_pass_set { qw(from to) }
sub opts_to_pass_get { qw(at) }

package Moose::Meta::Attribute::Custom::Trait::MultiValued::Ranges;
{
  $Moose::Meta::Attribute::Custom::Trait::MultiValued::Ranges::VERSION = '0.0.1_1';
}
{
  $Moose::Meta::Attribute::Custom::Trait::MultiValued::Ranges::DIST = 'Data-MultiValued';
}{
sub register_implementation { 'Data::MultiValued::AttributeTrait::Ranges' }
}

1;

__END__
=pod

=head1 NAME

Data::MultiValued::AttributeTrait::Ranges - attribute traits for attributes holding ranged values

=head1 VERSION

version 0.0.1_1

=head1 SYNOPSIS

  package My::Class;
  use Moose;
  use Data::MultiValued::AttributeTrait::Ranges;

  has stuff => (
    is => 'rw',
    isa => 'Int',
    traits => ['MultiValued::Ranges'],
    predicate => 'has_stuff',
    multi_accessor => 'stuff_tagged',
    multi_predicate => 'has_stuff_tagged',
  );

=head1 DESCRIPTION

This role consumes L<Data::MultiValued::AttributeTrait> and
specialises it to use L<Data::MultiValued::Ranges> as multi-value
storage:

=head2 C<multivalue_storage_class>

Returns C<'Data::MultiValued::Ranges'>.

=head2 C<opts_to_pass_set>

Returns C<('from', 'to')>.

=head2 C<opts_to_pass_get>

Returns C<('at')>.

=head1 AUTHOR

Gianni Ceccarelli <dakkar@thenautilus.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

