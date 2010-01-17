package App::MultiPerl::Repository;
use strict;
use warnings;
use Path::Class qw/dir/;
use File::Path qw/mkpath/;
use Scope::Guard;
use Cwd ();
use File::Basename qw/basename/;

sub shell {
    print "-- @_\n";
    my $ret = system(@_);
    if ($ret != 0) {
        die "Failed to execute '@_': $ret";
    }
}

sub prefix {
    my $class = shift;
    my $dir = $ENV{MULTIPERL_PREFIX} or die "missing \$ENV{MULTIPERL_PREFIX}\n";
    return dir($dir);
}

sub git_cmd {
    my $class = shift;
    shell('git', @_);
}

sub repo {
    my $class = shift;
    $ENV{MULTIPERL_REPOSITORY} || 'git://perl5.git.perl.org/perl.git'
}

sub init_repo_dir {
    my $class = shift;
    my $prefix = $class->prefix();
    unless (-d $prefix) {
        $prefix->mkpath() or die "cannot create directory: $prefix"
    }
    chdir $prefix or die "cannot chdir: $!";
    my $repo_dir = $class->prefix->subdir('repository');
    unless ( -d $repo_dir ) {
        $class->git_cmd('clone', $class->repo(), 'repository');
    }
    chdir $repo_dir or die "Cannot chdir: $!";
    $class->git_cmd('fetch');
}

sub install {
    my ($class, $version, @option) = @_;

    my $origdir = Cwd::getcwd();
    my $guard = Scope::Guard->new(sub { chdir $origdir });

    my $tag = "perl-$version";
    print "-- checkout $tag\n";
    my $id = join("-", $version, map { my $x = $_; $x =~ s/^-[a-zA-Z]//; $x } sort({ $a cmp $b } @option));
       $id =~ s/=/_/g; # for -DDEBUGGING=-g
    if (scalar(grep { $_ =~ /^-DDEBUGGING/ } @option) == 0) {
        push @option, '-DDEBUGGING'; # set -DDEBUGGING by default.
    }

    $class->init_repo_dir();

    $class->git_cmd(qw/clean -xdf/);
    $class->git_cmd(qw/reset --hard/);
    $class->git_cmd('checkout', $tag);

    my $prefix = File::Spec->catfile($class->prefix(), $id);
    shell('./Configure', '-des', q{-Dcc='ccache gcc'}, @option, "-Dprefix=$prefix");
    shell('make');
    # shell('make', 'test');
    shell('make', 'install');
}

sub list {
    my $class = shift;
    my $prefix = $class->prefix();
    die "missing multiperl directory, please install first: $prefix" unless -d $prefix;
    return grep !/repository$/, dir($prefix)->children;
}

sub run {
    my ($class, $version, @args) = @_;
    if ($version) {
        $class->run_target(dir($class->prefix(), $version), @args);
    } else {
        for my $target ($class->list) {
            print "-- @{[ basename($target) ]}\n";
            $class->run_target($target, @args);
        }
    }
}

sub run_target {
    my ($class, $target, @args) = @_;
    my $cmd = dir($target, 'bin', 'perl')->stringify;
    system($cmd, @args);
}

1;
