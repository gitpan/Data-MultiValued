package Data::MultiValued::AttributeTrait;
{
  $Data::MultiValued::AttributeTrait::VERSION = '0.0.1_4';
}
{
  $Data::MultiValued::AttributeTrait::DIST = 'Data-MultiValued';
}
use Moose::Role;
use namespace::autoclean;
use Data::MultiValued::AttributeAccessors;
use MooseX::Types::Moose qw(Str);
use Try::Tiny;
use namespace::autoclean;

# ABSTRACT: "base role" for traits of multi-valued Moose attributes


has 'full_storage_slot' => (
    is => 'ro',
    isa => Str,
    lazy_build => 1,
);
sub _build_full_storage_slot { shift->name . '__MULTIVALUED_STORAGE__' }


my @accs_to_multiply=qw(accessor reader writer predicate clearer);

for my $acc (@accs_to_multiply) {
    has "multi_$acc" => (
        is => 'ro',
        isa => Str,
        predicate => "has_multi_$acc",
    );
}


requires 'multivalue_storage_class';


requires 'opts_to_pass_set';


requires 'opts_to_pass_get';


around slots => sub {
    my ($orig, $self) = @_;
    return ($self->$orig(), $self->full_storage_slot);
};


sub set_full_storage {
    my ($self,$instance) = @_;

    my $ret = $self->multivalue_storage_class->new();
    $self->associated_class->get_meta_instance->set_slot_value(
        $instance,
        $self->full_storage_slot,
        $ret,
    );
    return $ret;
}


sub get_full_storage {
    my ($self,$instance) = @_;

    return $self->associated_class->get_meta_instance
        ->get_slot_value(
            $instance,
            $self->full_storage_slot,
        );
}


sub full_storage {
    my ($self,$instance) = @_;

    return $self->get_full_storage($instance)
        || $self->set_full_storage($instance);
}


sub accessor_metaclass { 'Data::MultiValued::AttributeAccessors' }


after install_accessors => sub {
    my ($self) = @_;

    my $class  = $self->associated_class;

    for my $meth (@accs_to_multiply) {
        my $type = "multi_$meth";
        my $check = "has_$meth";
        my $multi_check = "has_$type";
        next unless $self->$check || $self->$multi_check;

        my $name = $self->$type;
        if (!$name) {
            my $basename = $self->$meth;

            die 'MultiValued attribute trait is not compatible with subref accessors'
                if ref($basename);

            $name = "${basename}_multi";
        }

        $class->add_method(
            $self->_process_accessors($type => $name,0)
        );
    }
};

sub _filter_opts {
    my ($hr,@fields) = @_;

    my %ret;
    for my $f (@fields) {
        if (exists $hr->{$f}) {
            $ret{$f}=$hr->{$f};
        }
    }
    return \%ret;
}


sub load_multi_value {
    my ($self,$instance,$opts) = @_;

    my $opts_passed = _filter_opts($opts, $self->opts_to_pass_get);

    my $value;my $found=1;
    try {
        $value = $self->full_storage($instance)->get($opts_passed);
    }
    catch {
        unless (ref($_) && $_->isa('Data::MultiValued::Exceptions::NotFound')) {
            die $_;
        }
        $found = 0;
    };

    if ($found) {
        $self->set_raw_value($instance,$value);
    }
    else {
        $self->raw_clear_value($instance);
    }
}


sub raw_clear_value {
    my ($self,$instance) = @_;

    $self->associated_class->get_meta_instance
        ->deinitialize_slot(
            $instance,
            $self->name,
        );
}


sub store_multi_value {
    my ($self,$instance,$opts) = @_;

    my $opts_passed = _filter_opts($opts, $self->opts_to_pass_set);

    $opts_passed->{value} = $self->get_raw_value($instance);

    $self->full_storage($instance)->set($opts_passed);
}

our $dyn_opts = {};


before get_value => sub {
    my ($self,$instance) = @_;

    $self->load_multi_value($instance,$dyn_opts);
};


sub get_multi_value {
    my ($self,$instance,$opts) = @_;

    local $dyn_opts = $opts;

    return $self->get_value($instance);
}


after set_initial_value => sub {
    my ($self,$instance,$value) = @_;

    $self->store_multi_value($instance,$dyn_opts);
};


after set_value => sub {
    my ($self,$instance,$value) = @_;

    $self->store_multi_value($instance,$dyn_opts);
};

sub set_multi_value {
    my ($self,$instance,$opts,$value) = @_;

    local $dyn_opts = $opts;

    return $self->set_value($instance,$value);
}


before has_value => sub {
    my ($self,$instance) = @_;

    $self->load_multi_value($instance,$dyn_opts);
};

sub has_multi_value {
    my ($self,$instance,$opts) = @_;

    local $dyn_opts = $opts;

    return $self->has_value($instance);
}


after clear_value => sub {
    my ($self,$instance) = @_;

    $self->full_storage($instance)->clear($dyn_opts);
    return;
};

sub clear_multi_value {
    my ($self,$instance,$opts) = @_;

    local $dyn_opts = $opts;

    return $self->clear_value($instance);
}


sub get_multi_read_method  { 
    my $self   = shift;
    return $self->multi_reader || $self->multi_accessor
        || $self->get_read_method . '_multi';
}

sub get_multi_write_method  { 
    my $self   = shift;
    return $self->multi_writer || $self->multi_accessor
        || $self->get_write_method . '_multi';
}


sub _rebless_slot {
    my ($self,$instance) = @_;

    my $st = $self->get_full_storage($instance);
    return unless $st;

    bless $st, $self->multivalue_storage_class;
    $st->_rebless_storage;
}


sub _as_hash {
    my ($self,$instance) = @_;

    my $st = $self->get_full_storage($instance);
    return unless $st;

    return $st->_as_hash;
}

1;

__END__
=pod

=encoding utf-8

=head1 NAME

Data::MultiValued::AttributeTrait - "base role" for traits of multi-valued Moose attributes

=head1 VERSION

version 0.0.1_4

=head1 DESCRIPTION

Don't use this role directly, use
L<Data::MultiValued::AttributeTrait::Tags>,
L<Data::MultiValued::AttributeTrait::Ranges> or
L<Data::MultiValued::AttributeTrait::TagsAndRanges>.

This role (together with L<Data::MultiValued::AttributeAccessors>)
defines all the basic plumbing to glue C<Data::MultiValued::Tags> etc
into Moose attributes.

=head2 Implementation details

The multi-value object is stored in the instance slot named by the
L</full_storage_slot> attribute attribute. C<before> modifiers on
getters load the appropriate value from the multi-value object into
the regular instance slot, C<after> modifiers on setters store the
value from the regular instance slot into the multi-value object.

=head2 Attributes

This trait adds some attributes to the attribute declarations in your
class. Example:

  has stuff => (
    is => 'rw',
    isa => 'Int',
    traits => ['MultiValued::Tags'],
    predicate => 'has_stuff',
    multi_accessor => 'stuff_tagged',
    multi_predicate => 'has_stuff_tagged',
  );

=head1 ATTRIBUTES

=head2 C<full_storage_slot>

The instance slot to use to store the C<Data::MultiValued::Tags> or
similar object. Defaults to C<"${name}__MULTIVALUED_STORAGE__">, where
C<$name> is the attribute name.

=head2 C<multi_accessor>

=head2 C<multi_reader>

=head2 C<multi_writer>

=head2 C<multi_predicate>

=head2 C<multi_clearer>

The names to use for the various additional accessors. See
L<Class::MOP::Attribute> for details. These default to
C<"${name}_multi"> where C<$name> is the name of the corresponding
non-multi accessor. So, for example,

  has stuff => (
    is => 'rw',
    traits => ['MultiValued::Tags'],
  );

will create a C<stuff> read / write accessor and a C<stuff_multi> read
/ write tagged accessor.

=head1 METHODS

=head2 C<slots>

Adds the L</full_storage_slot> to the list of used slots.

=head2 C<set_full_storage>

Stores a new instance of L</multivalue_storage_class> into the
L</full_storage_slot> of the instance.

=head2 C<get_full_storage>

Retrieves the value of the L</full_storage_slot> of the instance.

=head2 C<full_storage>

Returns an instance of L</multivalue_storage_class>, either by
retrieving it from the instance, or by creating one (and setting it in
the instance). Calls L</get_full_storage> and L</set_full_storage>.

=head2 C<accessor_metaclass>

Makes sure that all accessors for this attribute are created via the
L<Data::MultiValued::AttributeAccessors> method meta class.

=head2 C<install_accessors>

After the regular L<Moose::Meta::Attribute> method, installs the
multi-value accessors.

Each installed normal accessor gets a multi-value version

You can add or rename the multi-value version by using the attributes
described above

If you are passing explicit subrefs for your accessors, things won't work.

=head2 C<load_multi_value>

Retrieves a value from the multi-value object, and stores it in the
regular slot in the instance. If the value is not found, clears the
slot.

This traps the
L<Data::MultiValued::Exceptions::NotFound|Data::MultiValued::Exceptions/Data::MultiValued::Exceptions::NotFound>
exception that may be thrown by the multi-value object, but re-throws
any other exception.

=head2 C<raw_clear_value>

Clears the instance slot. Does the same as
L<Moose::Meta::Attribute/clear_value>, but we need this method because
the other one gets changed by this trait.

=head2 C<store_multi_value>

Gets the value from the regular slot in the instance, and stores it
into the multi-value object.

=head2 C<get_value>

Before the normal method, calls L</load_multi_value>. Normally, no
options will be passed to the multi-value object C<get> method.

=head2 C<get_multi_value>

Sets the options that L</load_multi_value> will use, then calls L</get_value>.

The options are passed via an ugly C<local>ised package
variable. There might be a better way.

=head2 C<set_initial_value>

After the normal method, calls L</store_multi_value>.

=head2 C<set_value>

=head2 C<set_multi_value>

Just like L</get_value> and L</get_multi_value>, but calling
L</store_multi_value> after the regular C<set_value>

=head2 C<has_value>

=head2 C<has_multi_value>

Just like L</get_value> and L</get_multi_value>.

=head2 C<clear_value>

=head2 C<clear_multi_value>

Call the C<clear> method on the multi-value object.

=head2 C<get_multi_read_method>

=head2 C<get_multi_write_method>

Return the name of the reader or writer method, honoring
L</multi_reader>, L</multi_writer> and L</multi_accessor>.

=head1 REQUIREMENTS

These methods must be provided by any class consuming this role. See
L<Data::MultiValued::AttributeTrait::Tags> etc. for examples.

=head2 C<multivalue_storage_class>

The class to use to create the multi-value objects.

=head2 C<opts_to_pass_set>

Which options to pass from the multi-value accessors to the C<set>
method of the multi-value object.

=head2 C<opts_to_pass_get>

Which options to pass from the multi-value accessors to the C<get>
method of the multi-value object.

=head1 Serialisation helpers

These are used through
L<Data::MultiValued::UglySerializationHelperRole>.

=head2 C<_rebless_slot>

Blesses the value inside the L</full_storage_slot> of the instance
into L</multivalue_storage_class>, then calls C<_rebless_storage> on
it.

=head2 C<_as_hash>

Returns the result of calling C<_as_hash> on the value inside the
L</full_storage_slot> of the instance. Returns nothing if the slot
does not have a value.

=head1 AUTHOR

Gianni Ceccarelli <dakkar@thenautilus.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-Porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

