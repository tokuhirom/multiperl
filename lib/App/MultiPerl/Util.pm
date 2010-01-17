package App::MultiPerl::Util;
use strict;
use warnings;
use Exporter 'import';

our @EXPORT = qw/shell/;

sub shell {
    print "-- @_\n";
    my $ret = system(@_);
    if ($ret != 0) {
        die "Failed to execute '@_': $ret";
    }
}

1;
