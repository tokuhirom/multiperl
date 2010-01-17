use inc::Module::Install;
name 'App-MultiPerl';
all_from 'lib/App/MultiPerl.pm';

requires 'UNIVERSAL::require';
requires 'Path::Class';
requires 'Scope::Guard';

tests 't/*.t t/*/*.t t/*/*/*.t t/*/*/*/*.t';
test_requires 'Test::More';
test_requires 'YAML';
author_tests 'xt';
use_test_base;
auto_include;
WriteAll;
