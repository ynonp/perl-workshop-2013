/*global Handlebars */

(function(global) {

  var tf = Handlebars.compile($('#tmpl-table').html());

  var reload_contacts = function() {
    $.get('/contacts.json', function(data) {
      $('tbody').html(tf(data));
    });
  };

  $('form').on('submit', function() {
    $.post('/contacts/new', $(this).serialize(), reload_contacts );
    $('form input').val('');
    return false;
  });

  reload_contacts();

}(this));

