package Falcor2::Util;

use 5.20.1;
use warnings;

use Falcor2::ConfigLoader;

sub config {
   Falcor2::ConfigLoader->new(
      env_key => 'FALCOR2',
      config_class => 'Falcor2::Config',
   )->load
}

1;
