use strict;
use warnings;
use v5.14;
use MongoDB;
use Data::Printer;

my $client = MongoDB::MongoClient->new;
my $db = $client->get_database('demo');

my $coll = $db->get_collection('highscore');

$coll->remove( { score => { '$gt' => 80 } } );


