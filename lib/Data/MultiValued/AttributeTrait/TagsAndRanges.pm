package Data::MultiValued::AttributeTrait::TagsAndRanges;
{
  $Data::MultiValued::AttributeTrait::TagsAndRanges::VERSION = '0.0.1_3';
}
{
  $Data::MultiValued::AttributeTrait::TagsAndRanges::DIST = 'Data-MultiValued';
}
use Moose::Role;
use Data::MultiValued::TagsAndRanges;
with 'Data::MultiValued::AttributeTrait';

# ABSTRACT: attribute traits for attributes holding tagged and ranged values


sub multivalue_storage_class { 'Data::MultiValued::TagsAndRanges' };
sub opts_to_pass_set { qw(from to tag) }
sub opts_to_pass_get { qw(at tag) }

package Moose::Meta::Attribute::Custom::Trait::MultiValued::TagsAndRanges;
{
  $Moose::Meta::Attribute::Custom::Trait::MultiValued::TagsAndRanges::VERSION = '0.0.1_3';
}
{
  $Moose::Meta::Attribute::Custom::Trait::MultiValued::TagsAndRanges::DIST = 'Data-MultiValued';
}{
sub register_implementation { 'Data::MultiValued::AttributeTrait::TagsAndRanges' }
}

1;

__END__
=pod

=encoding utf-8

=head1 NAME

Data::MultiValued::AttributeTrait::TagsAndRanges - attribute traits for attributes holding tagged and ranged values

=head1 VERSION

version 0.0.1_3

=head1 SYNOPSIS

  package My::Class;
  use Moose;
  use Data::MultiValued::AttributeTrait::TagsAndRanges;

  has stuff => (
    is => 'rw',
    isa => 'Int',
    traits => ['MultiValued::TagsAndRanges'],
    predicate => 'has_stuff',
    multi_accessor => 'stuff_tagged',
    multi_predicate => 'has_stuff_tagged',
  );

=head1 DESCRIPTION

This role consumes L<Data::MultiValued::AttributeTrait> and
specialises it to use L<Data::MultiValued::TagsAndRanges> as multi-value
storage:

=head2 C<multivalue_storage_class>

Returns C<'Data::MultiValued::TagsAndRanges'>.

=head2 C<opts_to_pass_set>

Returns C<('tag', 'from', 'to')>.

=head2 C<opts_to_pass_get>

Returns C<('tag', 'at')>.

=head1 AUTHOR

Gianni Ceccarelli <dakkar@thenautilus.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-Porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

