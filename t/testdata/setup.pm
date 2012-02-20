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
    my $src = Path::Class::dir(qw(t testdata),$run);

    dircopy($src,$tempdir->subdir($run)) || die $!;
    my $mtime = $src->file('coverage.html')->stat->mtime;
    utime($mtime,$mtime,$tempdir->file($run,'coverage.html')->stringify);
    return $tempdir->subdir($run);
}

1;
