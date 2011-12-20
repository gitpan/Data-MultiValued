package Data::MultiValued::AttributeTrait::Tags;
{
  $Data::MultiValued::AttributeTrait::Tags::VERSION = '0.0.1_4';
}
{
  $Data::MultiValued::AttributeTrait::Tags::DIST = 'Data-MultiValued';
}
use Moose::Role;
use namespace::autoclean;
use Data::MultiValued::Tags;
with 'Data::MultiValued::AttributeTrait';

# ABSTRACT: attribute traits for attributes holding tagged values


sub multivalue_storage_class { 'Data::MultiValued::Tags' };
sub opts_to_pass_set { qw(tag) }
sub opts_to_pass_get { qw(tag) }

package Moose::Meta::Attribute::Custom::Trait::MultiValued::Tags;
{
  $Moose::Meta::Attribute::Custom::Trait::MultiValued::Tags::VERSION = '0.0.1_4';
}
{
  $Moose::Meta::Attribute::Custom::Trait::MultiValued::Tags::DIST = 'Data-MultiValued';
}{
sub register_implementation { 'Data::MultiValued::AttributeTrait::Tags' }
}

1;

__END__
=pod

=encoding utf-8

=head1 NAME

Data::MultiValued::AttributeTrait::Tags - attribute traits for attributes holding tagged values

=head1 VERSION

version 0.0.1_4

=head1 SYNOPSIS

  package My::Class;
  use Moose;
  use Data::MultiValued::AttributeTrait::Tags;

  has stuff => (
    is => 'rw',
    isa => 'Int',
    traits => ['MultiValued::Tags'],
    predicate => 'has_stuff',
    multi_accessor => 'stuff_tagged',
    multi_predicate => 'has_stuff_tagged',
  );

=head1 DESCRIPTION

This role consumes L<Data::MultiValued::AttributeTrait> and
specialises it to use L<Data::MultiValued::Tags> as multi-value
storage:

=head2 C<multivalue_storage_class>

Returns C<'Data::MultiValued::Tags'>.

=head2 C<opts_to_pass_set>

Returns C<('tag')>.

=head2 C<opts_to_pass_get>

Returns C<('tag')>.

=head1 AUTHOR

Gianni Ceccarelli <dakkar@thenautilus.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-Porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

