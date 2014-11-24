#!/usr/bin/env perl

use 5.20.1;
use warnings;

use IO::Async::Loop;
use Net::Async::HTTP::Server::PSGI;

use Falcor2::Util;
use Falcor2::Web;

my $loop = IO::Async::Loop->new;

my $handler = Net::Async::HTTP::Server::PSGI->new(
   app => Falcor2::Web->new(
      loop => $loop,
   )->to_psgi_app,
);
$loop->add($handler);
$handler->listen(
   host => '127.0.0.1',
   service => Falcor2::Util::config->port,
   socktype => 'stream',
   on_listen_error => sub { die $_[1] },
   on_resolve_error => sub { die $_[1] },
);

$loop->run;
