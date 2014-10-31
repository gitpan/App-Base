package App::Base::Script;

=head1 NAME

App::Base::Script - A truly lazy person's tool for writing self-documenting, self-monitoring scripts

=head1 VERSION

This document describes App::Base version 0.03

=head1 SYNOPSIS

    package MyScript;

    use Moose;
    with 'App::Base::Script';

    sub documentation { return 'This is a script.'; }

    sub script_run {
        my $self = shift;
        $self->info("Hello, world");
        return 0;
    }

    no Moose;
    __PACKAGE__->meta->make_immutable;

    package main;

    exit MyScript->new()->run();

=head1 DESCRIPTION

App::Base::Script builds on App::Base::Script::Common and provides common infrastructure that is
useful for writing scripts.

=head1 REQUIRED SUBCLASS METHODS

See also, L<App::Base::Script::Common> "REQUIRED METHODS"

=cut

use Moose::Role;
with 'App::Base::Script::Common';
our $VERSION = "0.03";
$VERSION = eval $VERSION;
use Carp qw( croak );
use Config;
use Try::Tiny;

=head2 script_run($self, @ARGS)

The code that actually executes the meat of the script. When a App::Base::Script is invoked
by calling run(), all of the relevant options parsing and error handling is performed
and then control is handed over to the script_run() method. The return value of script_run()
is returned as the return value of run().

=cut

requires 'script_run';

=head1 METHODS

=head2 The new() method

(See App::Base::Script::Common::new)

=cut

sub __run {
    my $self = shift;

    my $result;

    try { $result = $self->script_run(@{$self->parsed_args}); }
    catch {
        $self->error($_);
    };

    return $result;
}

=head2 error

Handles errors generated by the script. This results in a call
to App::Base::Script::Common::__error, which exits.

=cut

sub error {
    my $self = shift;
    return $self->__error(@_);
}

1;

__END__

=head1 USAGE

=head2 Invocation

Invocation of a App::Base::Script-based script is accomplished as follows:

=over 4

=item -

Define a class that implements the App::Base::Script interface (using 'with App::Base::Script')

=item -

Instantiate an object of that class via new()

=item -

Run the script by calling run(). The return value of run() is the exit
status of the script, and should typically be passed back to the calling
program via exit()

=back

=head2 Options handling

(See App::Base::Script::Common, "Options handling")

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2010-2014 Binary.com

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
