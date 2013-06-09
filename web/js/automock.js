$(document).ready(function() {
    if (window.File && window.FileReader) {
        // we have file api and js
        $('#err_api').hide(); //hide message
        $('#btn_submit').removeAttr('disabled'); //enable submit button
    }

    $('#btn_submit').click(function() {
        submit();
    })
});
