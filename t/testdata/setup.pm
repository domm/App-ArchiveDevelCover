package testdata::setup;
use strict;
use warnings;
use 5.010;

use File::Temp qw(tempdir);
use Path::Class;
use File::Copy::Recursive qw(dircopy);

sub tmpdir {
    my $tempdir = Path::Class::Dir->new(tempdir(CLEANUP=>$ENV{NO_CLEANUP} ? 0 : 1));
    return $tempdir;
}

sub run {
    my ($tempdir, $run) = @_;

    dircopy(Path::Class::dir(qw(t testdata), $run),$tempdir->subdir($run)) || die $!;
    return $tempdir->subdir($run);
}

1;
