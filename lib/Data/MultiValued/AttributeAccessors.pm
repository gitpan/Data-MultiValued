package Data::MultiValued::AttributeAccessors;
{
  $Data::MultiValued::AttributeAccessors::VERSION = '0.0.1_1';
}
{
  $Data::MultiValued::AttributeAccessors::DIST = 'Data-MultiValued';
}
use strict;
use warnings;
use base 'Moose::Meta::Method::Accessor';
use Carp 'confess';

sub _instance_is_inlinable { 0 }

sub _generate_accessor_method {
    my $self = shift;
    my $attr = $self->associated_attribute;

    return sub {
        if (@_ >= 2) {
            $attr->set_multi_value($_[0], {}, $_[1]);
        }
        $attr->get_multi_value($_[0], {});
    }
}

sub _generate_reader_method {
    my $self = shift;
    my $attr = $self->associated_attribute;

    return sub {
        confess "Cannot assign a value to a read-only accessor"
            if @_ > 1;
        $attr->get_multi_value($_[0], {});
    };
}

sub _generate_writer_method {
    my $self = shift;
    my $attr = $self->associated_attribute;

    return sub {
        $attr->set_multi_value($_[0], {}, $_[1]);
    };
}

sub _generate_predicate_method {
    my $self = shift;
    my $attr = $self->associated_attribute;

    return sub {
        $attr->has_multi_value($_[0], {})
    };
}

sub _generate_clearer_method {
    my $self = shift;
    my $attr = $self->associated_attribute;

    return sub {
        $attr->clear_multi_value($_[0], {})
    };
}

sub _generate_multi_accessor_method {
    my $self = shift;
    my $attr = $self->associated_attribute;

    return sub {
        if (@_ >= 3) {
            $attr->set_multi_value($_[0], $_[1], $_[2]);
        }
        $attr->get_multi_value($_[0],$_[1]);
    }
}

sub _generate_multi_reader_method {
    my $self = shift;
    my $attr = $self->associated_attribute;

    return sub {
        confess "Cannot assign a value to a read-only accessor"
            if @_ > 2;
        $attr->get_multi_value($_[0],$_[1]);
    };
}

sub _generate_multi_writer_method {
    my $self = shift;
    my $attr = $self->associated_attribute;

    return sub {
        $attr->set_multi_value($_[0], $_[1], $_[2]);
    };
}

sub _generate_multi_predicate_method {
    my $self = shift;
    my $attr = $self->associated_attribute;

    return sub {
        $attr->has_multi_value($_[0],$_[1])
    };
}

sub _generate_multi_clearer_method {
    my $self = shift;
    my $attr = $self->associated_attribute;

    return sub {
        $attr->clear_multi_value($_[0],$_[1])
    };
}

1;

__END__
=pod

=head1 NAME

Data::MultiValued::AttributeAccessors

=head1 VERSION

version 0.0.1_1

=head1 AUTHOR

Gianni Ceccarelli <dakkar@thenautilus.net>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Net-a-porter.com.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

