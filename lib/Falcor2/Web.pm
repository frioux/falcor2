package Falcor2::Web;

use 5.20.1;

use Web::Simple;
use warnings NONFATAL => 'all';
no warnings::illegalproto;

use experimental 'signatures', 'postderef';

use IPC::System::Simple 'capture';
use File::pushd;
use XML::Atom::Feed;
use XML::Atom::Entry;
use XML::Atom::Content;
use DateTime;
use Plack::Middleware::Auth::Basic;
use IO::Async::Timer::Absolute;
use Net::Async::HTTP;
use HTTP::Request::Common 'POST';

with 'Falcor2::HasConfig';

has _ua => (
   is => 'ro',
   default => sub ($self) {
      my $http = Net::Async::HTTP->new(
         user_agent => 'Falcor v2',
         timeout    => 180,
      );

      $self->_loop->add( $http );

      return $http
   },
);

has _loop => (
   is => 'ro',
   required => 1,
   init_arg => 'loop',
);

sub dispatch_request {
   '' => sub ($self, $env) {
      Plack::Middleware::Auth::Basic->new(
         authenticator => sub ($u, $p, $e) {
            $self->_config->verify_login($u, $p)
         }
      )
   },
   POST => sub {
      '/reload' => sub ($self, $) {
         my $f = $self->_config->remind_file;
         my $_d = pushd($f->absolute->filepath);

         for (capture('remind', '-n', $f->filename)) {
            if (my ($y, $m, $d, $h, $mi, $p, $message) = (m((\d{4})/(\d\d)/(\d\d) (\d\d?):(\d\d)([ap])m PUSH (.+)$))) {
               my $dt = DateTime->new(
                  hour => $h + ($p eq 'p' ? 12 : 0),
                  minute => $mi,
                  year => $y,
                  month => $m,
                  day => $d,
                  time_zone => 'local',
               );
               next if $dt < DateTime->now(time_zone => 'local');
               print STDERR "enqueing $message\n";
               $self->_loop->add(
                  IO::Async::Timer::Absolute->new(
                     time => $dt->epoch,

                     on_expire => sub {
                        print STDERR "sending $message\n";
                        $self->_ua->do_request(
                           on_error    => sub ($message, @) {
                              print STDERR " !! failure '$message'\n";
                           },
                           on_response => sub ($response) {
                              print STDERR "response to '$message': "
                                 . $response->status_line . "\n";
                           },
                           request => POST 'https://api.pushover.net/1/messages.json', {
                              message => $message,
                              token => $self->_config->pushover_token,
                              user => $self->_config->pushover_user,
                           },
                        )
                     },
                  )->start
               );
            }

         };

         [200, [ 'Content-type' => 'text' ], [ '' ]]
      },
   },
   GET => sub {
      '/feed' => sub ($self, $env) {
         my $f = $self->_config->remind_file;
         my $_d = pushd($f->absolute->filepath);

         my $feed = XML::Atom::Feed->new;
         $feed->title(q(Frew's Calendar));
         my $entry = XML::Atom::Entry->new;
         my $dt = DateTime->now->ymd('-');
         $entry->title($dt);
         $entry->id($dt);
         my $c = capture('remind', $f->filename);
         $entry->content(XML::Atom::Content->new(Type => 'xhtml', Body => "<pre>$c</pre>"));
         $feed->add_entry($entry);

         [ 200, [ 'Content-type', 'application/atom+xml' ], [$feed->as_xml] ]
     },
      '' => sub ($self, $env) {
         my $f = $self->_config->remind_file;
         my $_d = pushd($f->absolute->filepath);
         [ 200, [ 'Content-type', 'text/plain' ], [capture('remind', $f->filename) ] ]
     },
  }
}

1;
