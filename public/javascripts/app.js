$(document).ready(function() {
  var form = $("form"),
      urlInput = form.find("input[name='url']"),
      linkSuccess = $('.link-success'),
      linkError = $('.link-error');

  form.submit(function(event) {
    event.preventDefault();
    submitForm();
  });

  function submitForm() {
    var url = urlInput.val();

    clearSuccessAndError();
    $.post('/', { url: url }, 'json')
      .done(function(response) {
        displaySuccess(response.key);
      })
      .fail(function(errorResponse) {
        displayError($.parseJSON(errorResponse.responseText).message);
      });
  }

  function displaySuccess(shortlinkKey) {
    var innerHtml = 'Shortlink: <a href="/' + shortlinkKey + '">' +
                      document.location.hostname + '/' + shortlinkKey +
                    '</a>';
    linkSuccess.html(innerHtml);
  }

  function displayError(message) {
    var innerHtml = '<span>' + message + '</span>';
    linkError.html(innerHtml);
  }

  function clearSuccessAndError() {
    linkSuccess.empty();
    linkError.empty();
  }
});
