package Falcor2::ConfigLoader;

use utf8;
use Moo;
use warnings NONFATAL => 'all';

use JSON::MaybeXS;
use IO::All;
use Try::Tiny;
use Module::Runtime 'use_module';
use namespace::clean;

has _env_key => (
   is => 'ro',
   init_arg => 'env_key',
   required => 1,
);

has _location => (
   is => 'ro',
   init_arg => undef,
   lazy => 1,
   default => sub {
      $ENV{$_[0]->env_key . 'CONFLOC'} // $_[0]->__location
   },
);

has __location => (
   is => 'ro',
   init_arg => 'location',
   default => '../config',
);

has _config_class => (
   is => 'ro',
   init_arg => 'config_class',
   required => 1,
);

sub _io { io->file($_[0]->_location . '.json') }

sub _read_config_from_file {
   try {
      decode_json($_[0]->_io->slurp)
   } catch {
      {}
   }
}

sub _read_config_from_env {
   my $k_re = '^' . quotemeta($_[0]->_env_key) . 'CONFVAL_(.+)';

   +{
      map {; m/$k_re/; lc $1 => $ENV{$_[0]->_env_key . "CONFVAL_$1"} }
      grep m/$k_re/,
      keys %ENV
   }
}

sub _read_config {
   {
      %{$_[0]->_read_config_from_file},
      %{$_[0]->_read_config_from_env},
   }
}

sub load { use_module($_[0]->_config_class)->new($_[0]->_read_config) }

sub store {
   shift->_io->print(encode_json(shift->as_hash))
}

1;

