use 5.010;
use strict;
use warnings;
use lib qw(t);

use Test::Most;
use Test::Trap;
use Test::File;
use testdata::setup;
use App::ArchiveDevelCover;

my $temp = testdata::setup::tmpdir();

{ # first archive
    my $run = testdata::setup::run($temp,'run_1');

    my $a = App::ArchiveDevelCover->new(
        from=>$run,
        to=>$temp->subdir('archive'),
        project=>'first test',
    );
    trap { $a->run; };
    is ( $trap->exit, undef, 'exit() == undef' );
    like($trap->stdout,qr/archived coverage reports at $temp/,'command output location');

    foreach my $file (qw(index.html cover.css archive_db 2012-02-20T19:56:58/coverage.html)) {
        file_exists_ok($temp->file('archive',$file));
    }
}

{ # archive the same run again
    my $a = App::ArchiveDevelCover->new(
        from=>$temp->subdir('run_1'),
        to=>$temp->subdir('archive'),
    );
    trap { $a->run; };
    is ( $trap->exit, 0, 'exit() == 0' );
    like($trap->stdout,qr/This coverage report has already been archived/i,'command output again');
}

{ # archive second run
    my $run = testdata::setup::run($temp,'run_2');

    my $a = App::ArchiveDevelCover->new(
        from=>$run,
        to=>$temp->subdir('archive'),
    );
    trap { $a->run; };
    is ( $trap->exit, undef, 'exit() == undef' );
    like($trap->stdout,qr/archived coverage reports at $temp/,'command output location');

    foreach my $file (qw(index.html cover.css archive_db 2012-02-20T20:28:36/coverage.html)) {
        file_exists_ok($temp->file('archive',$file));
    }
    my @archive = $temp->file('archive','archive_db')->slurp;
    is(@archive,2,'2 lines in archive_db');

    my $l1 = shift(@archive);
    chomp($l1);
    my @d1 = split(/;/,$l1);
    is($d1[3],'18.5','first line total coverage');

    my $l2 = shift(@archive);
    chomp($l2);
    my @d2 = split(/;/,$l2);
    is($d2[3],'76.2','second line total coverage');
}

done_testing();
