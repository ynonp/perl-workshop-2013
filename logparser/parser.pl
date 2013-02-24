use strict;
use warnings;
use v5.14;
use autodie;

use File::Touch;
use MongoDB;
use Data::Printer;

my $logdir       = 'logs';
my @users        = qw/Kirk Spock Bones Scott Chekov Rand/;
my @transactions = qw/deposit withdraw/;
my @lognames     = map { "$logdir/$_.log" } (1..100);

my $client = MongoDB::MongoClient->new;
my $db     = $client->get_database('logs');
my $coll   = $db->get_collection( 'logs' );
my $orders = $db->get_collection( 'orders' );

########################################
#
# Creating random log data
#
sub fill_log_file {
  my ( $logfile ) = @_;
  open my $fh, '>', $logfile;

  my $num_records = int(rand(999));
  for ( 1..$num_records ) {
    my $user             = @users[rand @users];
    my $num_transactions = int(rand(10));

    say {$fh} "uid: $user";

    for ( 1..$num_transactions ) {
      my $action = $transactions[rand @transactions];
      my $param  = rand(100);

      say {$fh} "$action $param";
    }
  }

  close $fh;
}

sub create_dummy_data {
  mkdir $logdir     unless -d $logdir;

  touch @lognames;
  fill_log_file($_) for @lognames;
}



########################################
#
# Read all log files into DB
# and add a status field
#
sub init_db {
  $coll->remove();
  $orders->remove();

  foreach my $logfile ( @lognames ) {
    $coll->insert( { filename => $logfile, status => 0 } );
  }
}


########################################
#
# Read single log file and insert 
# the results back to the DB
#
sub parse_log_file {
  my ( $filename ) = @_;
  open my $fh, '<', $filename;
  my $uid;
  my %result;

  while(<$fh>) {
    if ( /^uid: (.*)$/ ) {
      $uid = $1;
      next;
    }

    my ( $action, $amount ) = /^(\w+) \s ([\d.]+)/x;
    next if ! $action;

    $action eq 'deposit' && ( $amount *= -1 );
    $orders->insert({ username => $uid, amount => $amount });
  }
}

########################################
#
# Fetch a single task from DB
# execute it, and update its status
#
sub parse_one_from_db {
  my ( $task ) = @_;

  warn 'parsing: ', p $task;
  my $filename = $task->{filename};

  parse_log_file( $filename );
  $task->{status} = 2;

  $coll->save( $task );
}

########################################
#
# Main program loop:
#   Find an open task
#   Execute it
#
sub parse_db {
  while ( my $task = $coll->find_and_modify({
        query  => { status => 0 },
        update => { status => 1 },
      }))
    {
      parse_one_from_db( $task );
    }
}


my %commands = (
  init_logs  => \&create_dummy_data,
  init_db    => \&init_db,
  parse      => \&parse_db,
);

$commands{$_}->() for ( grep { exists $commands{$_} } @ARGV );

