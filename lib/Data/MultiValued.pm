package Data::MultiValued;
{
  $Data::MultiValued::VERSION = '0.0.1_4';
}
{
  $Data::MultiValued::DIST = 'Data-MultiValued';
}
use strict;
use warnings;
# ABSTRACT: store tag- and range-dependant data in a scalar or Moose attribute

warn "Don't use this module directly, use Data::MultiValued::Tags or Data::MultiValued::Ranges or the like";

1;


__END__
=pod

=encoding utf-8

=head1 NAME

Data::MultiValued - store tag- and range-dependant data in a scalar or Moose attribute

=head1 VERSION

version 0.0.1_4

=head1 SYNOPSIS

  use Data::MultiValued::Tags;

  my $obj = Data::MultiValued::Tags->new();
  $obj->set({
    tag => 'tag1',
    value => 'a string',
  });
  say $obj->get({tag=>'tag1'}); # prints 'a string'
  say $obj->get({tag=>'tag2'}); # dies

Also:

  package My::Class;
  use Moose;
  use Data::MultiValued::AttributeTrait::Tags;

  has stuff => (
    is => 'rw',
    isa => 'Int',
    traits => ['MultiValued::Tags'],
  );

  # later

  my $obj = My::Class->new();
  $obj->stuff_multi({tag=>'tag1'},123);
  say $obj->stuff_multi({tag=>'tag1'}); # prints 123

=head1 DESCRIPTION

This set of classes allows you to store different values inside a
single object, and access them by tag and / or by a numeric value.

Yes, you could do the same with hashes and some clever use of
arrays. Or you could use L<Array::IntSpan>. Or some other CPAN
module. Why use these?

=over 4

=item *

they are optimised for serialisation, see
L<Data::MultiValued::UglySerializationHelperRole> and F<t/json.t>.

=item *

you get accessors generated for your Moose attributes just by setting
a trait

=item *

tags and ranges interact in sensible ways, including clearing ranges

=back

=head1 Where to go from here

Look at the tests for detailed examples of usage. Look at
L<Data::MultiValued::Tags>, L<Data::MultiValued::Ranges> and
L<Data::MultiValued::TagsAndRanges> for the containers
themselves. Look at L<Data::MultiValued::AttributeTrait::Tags>,
L<Data::MultiValued::AttributeTrait::Ranges> and
L<Data::MultiValued::AttributeTrait::TagsAndRanges> for the Moose
attribute traits.

=head1 AUTHOR

Gianni Ceccarelli <dakkar@thenautilus.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-Porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

