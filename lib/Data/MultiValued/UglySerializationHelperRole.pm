package Data::MultiValued::UglySerializationHelperRole;
{
  $Data::MultiValued::UglySerializationHelperRole::VERSION = '0.0.1_3';
}
{
  $Data::MultiValued::UglySerializationHelperRole::DIST = 'Data-MultiValued';
}
use Moose::Role;

# ABSTRACT: only use this if you know what you're doing


sub new_in_place {
    my ($class,$hash) = @_;

    my $self = bless $hash,$class;

    for my $attr ($class->meta->get_all_attributes) {
        if ($attr->does('Data::MultiValued::AttributeTrait')) {
            $attr->_rebless_slot($self);
        }
    }
    return $self;
}


sub as_hash {
    my ($self) = @_;

    my %ret = %$self;
    for my $attr ($self->meta->get_all_attributes) {
        if ($attr->does('Data::MultiValued::AttributeTrait')) {
            my $st = $attr->_as_hash($self);
            if ($st) {
                $ret{$attr->full_storage_slot} = $st;
            }
            else {
                delete $ret{$attr->full_storage_slot};
            }
        }
    }
    return \%ret;
}


1;

__END__
=pod

=encoding utf-8

=head1 NAME

Data::MultiValued::UglySerializationHelperRole - only use this if you know what you're doing

=head1 VERSION

version 0.0.1_3

=head1 SYNOPSIS

 package My::Class;
 use Moose;
 use Data::MultiValued::AttributeTrait::Tags;

 with 'Data::MultiValued::UglySerializationHelperRole';

 has tt => (
    is => 'rw',
    isa => 'Int',
    traits => ['MultiValued::Tags'],
    default => 3,
    predicate => 'has_tt',
    clearer => 'clear_tt',
 );

Later:

  my $json = JSON::XS->new->utf8;
  my $obj = My::Class->new(rr=>'foo');

  my $str = $json->encode($obj->as_hash);

  my $obj2 = My::Class->new_in_place($json->decode($str));

  # $obj and $obj2 have the same contents

=head1 DESCRIPTION

This is an ugly hack. It pokes inside the internals of your objects,
and will break if you're not careful. It assumes that your instances
are hashref-based. It mostly assumes that you're not storing blessed
refs inside the multi-value attributes. It goes to these lengths to
give a decent serialisation performance, without lots of unnecessary
copies. Oh, and on de-serialise it will skip all type constraint
checking and bypass the accessors, so it may well give you an unusable
object.

=head1 METHODS

=head2 C<new_in_place>

  my $obj = My::Class->new_in_place($hashref);

Directly C<bless>es the hashref into the class, then calls
C<_rebless_slot> on any multi-value attribute.

This is very dangerous, don't try this at home without the supervision
of an adult.

=head2 C<as_hash>

  my $hashref = $obj->as_hash;

Performs a shallow copy of the object's hash, then replaces the values
of all the multi-value slots with the results of calling C<_as_hash>
on the corresponding multi-value attribute.

This is very dangerous, don't try this at home without the supervision
of an adult.

=head1 FINAL WARNING

 my $obj_clone = My::Class->new_in_place($obj->as_hash);

This will create a shallow clone. Most internals will be
shared. Things may break. Just don't do it, C<dclone> the hashref, or
do something equivalent (as in the synopsis), instead.

=head1 AUTHOR

Gianni Ceccarelli <dakkar@thenautilus.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-Porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

