package Falcor2::HasConfig;

use utf8;
use Moo::Role;
use warnings NONFATAL => 'all';

has _config => (
   is => 'ro',
   lazy => 1,
   default => \&Falcor2::Util::config,
);

1;
