#!/usr/bin/env perl

use 5.18.2;
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
   host => '0.0.0.0',
   service => Falcor2::Util::config->port,
   socktype => 'stream',
   on_listen_error => sub { die $_[1] },
   on_resolve_error => sub { die $_[1] },
   on_listen => sub {
      print STDERR "listening on: " . $_[0]->read_handle->sockhost .
         ':' . $_[0]->read_handle->sockport . "\n";
   },
);

$loop->run;
