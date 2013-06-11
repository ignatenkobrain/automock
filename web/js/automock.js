var sg = "";

$(document).ready(function() {

    var key = "";
    var test = null;

    //key can be remembered in the browser
    readkey(document.getElementById('rsa_key').files[0]);

    if (window.File && window.FileReader) {
        // we have file api and js
        $('#err_api').hide();
        $('#btn_submit').removeAttr('disabled');
    }

    $('#btn_submit').click(function() {
        $('#err_read').hide();
        /*
        if (key) {
            openpgp.init();
            var pub_key = openpgp.read_publicKey(key);
            var source = $('#repo').val() + '?' + $('#branch').val();
            var signature = openpgp.write_encrypted_message(pub_key, hex_sha256(source));
            
            sg = signature;
            $.post("test.php", {
                src: source,
                sign: signature
            }, function(data) {
                alert("Answer: " + data);
            });
        }
        else {
            $('#err_read').show(100);
        } */
        
        var source = $('#repo').val();
        var branch = $('#branch').val();
        $.post("build.php", {
            src: source,
            branch: branch,
            sign: 'none'
        }, function(data) {
            alert("Answer: " + data);
        });
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
