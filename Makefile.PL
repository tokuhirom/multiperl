use inc::Module::Install;
name 'App-MultiPerl';
all_from 'multiperl';

requires 'Path::Class';
requires 'LWP::UserAgent';
requires 'File::HomeDir';
requires 'Archive::Tar';

install_script 'multiperl';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More';
test_requires 'YAML';
author_tests 'xt';
auto_include;
WriteAll;
