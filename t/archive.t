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

    foreach my $file (qw(index.html cover.css archive_db)) {
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

done_testing();
