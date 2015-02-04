package Falcor2::Config;

use utf8;
use Moo;
use IO::All;
use warnings NONFATAL => 'all';

use Authen::Passphrase;

use namespace::clean;

has user => (
   is => 'ro',
   default => 'frew',
);

has port => (
   is => 'ro',
   default => 5003,
);

has password => (
   is => 'ro',
   default => '$2a$13$Z80Lh2fzaUTuUb3wuuyRjubFtHV97FhpIEkWwBYdCDAxXihGK4EqW',
);

sub _verify_password {
   Authen::Passphrase->from_crypt(shift->password)->match(shift)
}

sub verify_login {
   # silly and overengineered way to avoid side-channel timing attacks
   my $u_eq = $_[1] eq $_[0]->user;
   my $p_eq = $_[0]->_verify_password($_[2]);
   if (int rand 2) {
      $u_eq && $p_eq
   } else {
      $p_eq && $u_eq
   }
}

has pushover_user => (
   is => 'ro',
);

has pushover_token => (
   is => 'ro',
);

has remind_path => (
   is => 'ro',
   required => 1,
   isa => sub {
      die "remind path must be a real file!" unless -f $_[0]
   },
);

sub remind_file { io->file(shift->remind_path) }

sub as_hash {
   return {
      map { $_ => $_[0]->$_ }
      qw(user password pushover_user pushover_token remind_path)
   }
}

1;
