package contacts_perl;
use Dancer ':syntax';
use MongoDB;

our $VERSION = '0.1';

my $client = MongoDB::MongoClient->new(
  host => 'ds031957.mongolab.com',
  port => 31957);
$client->authenticate( 'demo', 'ynon', '123456' );

my $contacts_coll = $client->get_database('demo')->get_collection('pc');

get '/' => sub {
  send_file( 'index.html' );
};

get '/contacts.json' => sub {
  content_type 'application/json';

  my $cursor = $contacts_coll->find();

  return to_json({
      contacts => [$cursor->all]
  });
};

post '/contacts/new' => sub {
  my $name = param 'name';
  my $email = param 'email';

  $contacts_coll->insert(
      { name => $name, email => $email }
    );
};


true;
