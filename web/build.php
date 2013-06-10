<?php

    //get params
    $src = $_POST['src'];
    $sign = $_POST['sign'];
    $hash = hash('sha256', $src);

    //decrypt hash
    $pgp = gnupg_init();
    gnupg_adddecryptkey($pgp, $PGPKEY);
    $origin = gnupg_decrypt($pgp, $sign);

    if ($hash == $origin) {
        //ok
        echo 'ok';
    }
    else {
        http_response_code(403);
        echo 'no access';
        die();
    }
?>

