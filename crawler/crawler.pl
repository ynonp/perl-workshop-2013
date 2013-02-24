use strict;
use warnings;
use v5.14;
use Crawler;

my $c = Crawler->new;

# $c->add_url('http://www.google.com');
$c->listen();

