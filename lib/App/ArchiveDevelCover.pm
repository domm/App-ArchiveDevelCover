package App::ArchiveDevelCover;
use 5.010;
use Moose;
use MooseX::Types::Path::Class;
use DateTime;
use File::Copy;
use HTML::TableExtract;

with 'MooseX::Getopt';

has [qw(from to)] => (is=>'ro',isa=>'Path::Class::Dir',coerce=>1,required=>1,);
has 'project' => (is => 'ro', isa=>'Str');
has 'coverage_html' => (is=>'ro',isa=>'Path::Class::File',lazy_build=>1);
sub _build_coverage_html {
    my $self = shift;
    if (-e $self->from->file('coverage.html')) {
        return $self->from->file('coverage.html');
    }
    else {
        say "Cannot find 'coverage.html' in ".$self->from.'. Aborting';
        exit;
    }
}
has 'runtime' => (is=>'ro',isa=>'DateTime',lazy_build=>1,traits=> ['NoGetopt'],);
sub _build_runtime {
    my $self = shift;
    return DateTime->from_epoch(epoch=>$self->coverage_html->stat->mtime);
}

sub run {
    my $self = shift;
    $self->archive;

}

sub archive {
    my $self = shift;

    my $from = $self->from;
    my $target = $self->to->subdir($self->runtime->iso8601);

    if (-e $target) {
        say "This coverage report has already been archived.";
        exit;
    }

    $target->mkpath;
    my $target_string = $target->stringify;

    while (my $f = $from->next) {
        next unless $f=~/\.(html|css)$/;
        copy($f->stringify,$target_string) || die "Cannot copy $from to $target_string: $!";
    }

    say "archived coverage reports at $target_string";
}

#sub update_index {
#    my $self = shift;
#
#    my $te = HTML::TableExtract->new( headers => [qw(file	stmt	bran	cond	sub	time	total)] );
#    $te->parse(scalar $from->file('coverage.html')->slurp);
#    my $rows =$te->rows;
#    my $last_row = $rows->[-1];
#    my $date = $runtime->ymd('-').' '.$runtime->hms;
#    my $sub = $last_row->[4];
#    my $total = $last_row->[6];
#
#    my $new_stat = "\n<tr><td>$date</td><td>$sub</td><td>$total</td></tr>\n";
#
#    my $old_index = $self->to->file('index.html')->slurp;
#    $old_index =~ s/(<!-- INSERT -->)/$1 . $new_stat/e;
#
#    my $fh = $self->to->file('index.html')->openw;
#    print $fh $old_index;
#    close $fh;
#}
#

__PACKAGE__->meta->make_immutable;
1;


