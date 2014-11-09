package App::Base::Script::OnlyOne;
use Moose::Role;
our $VERSION = "0.03";
$VERSION = eval $VERSION;

use Path::Tiny;
use File::Flock::Tiny;

=head1 NAME

App::Base::Script::OnlyOne - do not allow more than one instance running

=head1 VERSION

This document describes App::Base version 0.03

=head1 SYNOPSIS

    use Moose;
    extends 'App::Base::Script';
    with 'App::Base::Script::OnlyOne';

=head1 DESCRIPTION

With this role your script will refuse to start if another copy of the script
is running already (or if it is deadlocked or entered an infinite loop because
of programming error). After start it tries to lock pid file, and if this is
not possible, it croaks.

=cut

around script_run => sub {
    my $orig = shift;
    my $self = shift;

    my $class   = ref $self;
    my $piddir  = $ENV{APP_BASE_DAEMON_PIDDIR} || '/var/run';
    my $pidfile = path($piddir)->child("$class.pid");
    my $lock    = File::Flock::Tiny->write_pid("$pidfile");
    die "Couldn't lock pid file, probably $class is already running" unless $lock;

    return $self->$orig(@_);
};

1;

__END__

=head1 LICENSE AND COPYRIGHT

Copyright (C) 2010-2014 Binary.com

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.

=cut
