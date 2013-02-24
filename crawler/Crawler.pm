package Crawler;
use Moose;
use strict;
use warnings;
use v5.14;
use MongoDB;
use Tie::IxHash;

has 'conn', is => 'ro', lazy_build => 1;

sub _build_conn {
  my $client =  MongoDB::MongoClient->new(host => 'localhost', port => 27017);
}

sub init_db {
  my $self = shift;
  my $cmd = Tie::IxHash->new("create" => "urls",
        "capped" => boolean::true,
        "size" => 10240,
        "max" => 100);

  $self->conn->get_database('crawler')->run_command($cmd);
}


sub db {
  my ( $self ) = @_;
  return $self->conn->get_database('crawler')->get_collection('urls');
}


sub add_url {
  my ( $self, $url ) = @_;
  $self->db->insert({ url => $url });
}

sub listen {
  my ( $self ) = @_;

  my $cursor = $self->db->find->tailable(1);

  while (1) {
    while ( $cursor->has_next ) {
      my $obj = $cursor->next;
      my $url = $obj->{url};
      say "Crawling for: $url";
    }
    say "next";
  }


}

1;
