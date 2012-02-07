#!/usr/bin/env perl
use 5.010;
use strict;
use warnings;

# ABSTRACT: script to archive Devel::Cover reports
# PODNAME: archive_devel_cover.pl

use App::ArchiveDevelCover;
App::ArchiveDevelCover->new_with_options->run;

