$(document).ready(function() {
  var form = $("form"),
      urlInput = form.find("input[name='url']"),
      linkAlertSuccess = $('.link-alert-success'),
      linkAlertError = $('.link-alert-error');

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
    linkAlertSuccess.html(innerHtml);
  }

  function displayError(message) {
    var innerHtml = '<span>' + message + '</span>';
    linkAlertError.html(innerHtml);
  }

  function clearSuccessAndError() {
    linkAlertSuccess.empty();
    linkAlertError.empty();
  }
});
