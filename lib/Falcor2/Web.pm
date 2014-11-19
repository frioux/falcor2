package Falcor2::Web;

use 5.20.1;

use experimental 'signatures', 'postderef';

use Web::Simple;
use warnings NONFATAL => 'all';
no warnings::illegalproto;

use IPC::System::Simple 'capture';
use File::pushd;
use IO::All;
use XML::Atom::Feed;
use XML::Atom::Entry;
use XML::Atom::Content;
use DateTime;
use Plack::Middleware::Auth::Basic;

sub dispatch_request {
   '' => sub {
      Plack::Middleware::Auth::Basic->new(
         authenticator => sub ($u, $p, $e) {
            "$u.$p" eq "$ENV{FALCOR_USER}.$ENV{FALCOR_PASS}"
         }
      )
  },
   GET => sub {
      '/feed' => sub {
         my $f = io->file($ENV{REMIND_PATH});
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
      '' => sub {
         my $f = io->file($ENV{REMIND_PATH});
         my $_d = pushd($f->absolute->filepath);
         [ 200, [ 'Content-type', 'text/plain' ], [capture('remind', $f->filename) ] ]
     },
  }
}

1;
