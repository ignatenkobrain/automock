$(document).ready(function() {

    var key = "";
    var test = null;

    readkey(document.getElementById('rsa_key').files[0]);

    if (window.File && window.FileReader) {
        // we have file api and js
        $('#err_api').hide();
        $('#btn_submit').removeAttr('disabled');
    }

    $('#btn_submit').click(function() {
        $('#err_read').hide();

        if (key) {
            alert(key);
        }
        else {
            $('#err_read').show(100);
        }
    })

    function readkey(keyfile) {
        var reader = new FileReader();
        if (keyfile) {
            reader.onload = function(red) {
                key = red.target.result;
            }
            reader.readAsText(keyfile); 
        }
    }

    $('#rsa_key').on("change ready", function(selected) {
        var file = selected.target.files[0];
        readkey(file);
    });
});
