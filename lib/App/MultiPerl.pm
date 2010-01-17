package App::MultiPerl;
use strict;
use warnings;
use 5.00800;
our $VERSION = '0.01';
use App::MultiPerl::Repository;
use Pod::Usage qw/pod2usage/;
use File::Basename;

sub repo () { 'App::MultiPerl::Repository' } ## no critic

sub run {
    my $class = shift;
    if ($class->can($ARGV[0])) {
        my $meth = shift @ARGV;
        return $class->$meth();
    }
    return $class->execute();
}

sub execute {
    my $class = shift;
    my $target;
    if (@ARGV > 0 && $ARGV[0] =~ /^--target=(.+)$/) {
        $target = $1;
    }
    repo->run($target, @ARGV);
}

sub install {
    unless (@ARGV) {
        die "Usage: $0 install 5.10.0";
    }
    repo->install(@ARGV);
}

sub list {
    my @list = repo->list(@ARGV);
    print join"\n",  map { basename($_) } @list;
    print "\n";
}

1;
__END__

=encoding utf8

=head1 NAME

App::MultiPerl -

=head1 SYNOPSIS

  use App::MultiPerl;

=head1 DESCRIPTION

App::MultiPerl is

=head1 AUTHOR

Tokuhiro Matsuno E<lt>tokuhirom AAJKLFJEF GMAIL COME<gt>

=head1 SEE ALSO

=head1 LICENSE

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself.

=cut
