package Falcor2::Config;

use utf8;
use Moo;
use IO::All;
use warnings NONFATAL => 'all';

use Authen::Passphrase;

use namespace::clean;

use experimental 'signatures';

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

sub _verify_password ($self, $pass) {
   Authen::Passphrase->from_crypt($self->password)->match($pass)
}

sub verify_login ($self, $u, $p) {
   # silly and overengineered way to avoid side-channel timing attacks
   my $u_eq = $u eq $self->user;
   my $p_eq = $self->_verify_password($p);
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

sub remind_file ($self) { io->file($self->remind_path) }

sub as_hash ($self) {
   return {
      map { $_ => $self->$_ }
      qw(user password pushover_user pushover_token remind_path)
   }
}

1;
