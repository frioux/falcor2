package Falcor2::ConfigLoader;

use utf8;
use Moo;
use warnings NONFATAL => 'all';

use experimental 'signatures';

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
   default => sub ($self) {
      $ENV{$self->env_key . 'CONFLOC'} // $self->__location
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

sub _io ($self) { io->file($self->_location . '.json') }

sub _read_config_from_file ($self) {
   try {
      decode_json($self->_io->slurp)
   } catch {
      {}
   }
}

sub _read_config_from_env ($self) {
   my $k_re = '^' . quotemeta($self->_env_key) . 'CONFVAL_(.+)';

   +{
      map {; m/$k_re/; lc $1 => $ENV{$self->_env_key . "CONFVAL_$1"} }
      grep m/$k_re/,
      keys %ENV
   }
}

sub _read_config ($self) {
   {
      %{$self->_read_config_from_file},
      %{$self->_read_config_from_env},
   }
}

sub load ($self) { use_module($self->_config_class)->new($self->_read_config) }

sub store ($self, $obj) {
   $self->_io->print(encode_json($obj->as_hash))
}

1;

